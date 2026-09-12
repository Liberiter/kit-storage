#!/usr/bin/env bash
# world를 초기 상태로 복원한다 (챕터 상태 연속성 수단).
# 모든 챕터는 초기 상태에서 시작한다 — world를 바꾸는 실습(6·7·8·10·11·12장, 마지막 평가 장)의
# 전후, 그리고 검증 러너의 변경형 케이스 전후에 실행한다.
# 두 경로 모두에서 동작한다: KIT_MODE=docker / KIT_MODE=native.
# KIT_MODE를 지정하지 않으면 setup.sh가 구축에 쓴 경로를 따른다 (kit_psql.sh 「구축 경로 기억」).
#
# 되돌리는 범위: 스키마 public(책숲 운영 world), legacy(6장 비정규 원장),
# antipatterns(8장 안티패턴 조각) 셋을 지우고 다시 만든다. 여러분이 만든 인덱스·뷰·
# 함수·트리거·추가 스키마 가운데 이 세 스키마 안의 것은 함께 사라진다.
#
# **실패하면 반드시 말한다.** 되돌리기가 실패한 것을 모르면 이후 출력이 전부 본문과
# 갈린다. 성공 시에는 조용하되(한 줄), 실패 시에는 psql의 출력을 삼키지 않고 원인 한 줄
# + 다음 행동 한 줄을 낸다.
set -euo pipefail
cd "$(dirname "$0")"
. ./kit_psql.sh

DB="$KIT_DB"

fail() { # $1=원인, $2=다음에 할 일, $3=종료 코드(기본 1)
  echo "reset 실패: $1" >&2
  [ "${2:-}" = "" ] || echo "  다음: $2" >&2
  exit "${3:-1}"
}

# 검증 러너가 이 world를 쓰는 동안에는 되돌리지 않는다 — 그 실행의 전제 상태를
# 지우고, 서로의 락이 엉켜 world 자체가 깨질 수 있다.
# 러너 자신이 부르는 reset은 KIT_LOCK_HELD로 알아본다 (kit_psql.sh 「러너 동시 실행 보호」).
lock_owner="$(kit_lock_owner)"
if [ -n "$lock_owner" ] && [ "$lock_owner" != "${KIT_LOCK_HELD:-}" ]; then
  fail "검증 러너(PID $lock_owner)가 같은 world($(kit_lock_target))를 쓰는 중입니다 — 지금 되돌리면 그 실행의 결과가 깨지고 world가 손상될 수 있습니다" \
       "그 실행이 끝난 뒤 다시 실행하세요 (이 터미널에서 돌린 게 아니라면 다른 터미널이나 다른 폴더에 받아 둔 kit의 ./verify.sh·./entry_check.sh·./concurrency.sh 입니다)" 2
fi

# 경로별 사전 점검 — 여기서 걸리면 psql을 부르기 전에 원인을 특정할 수 있다.
kit_runtime_check "reset"

# 아래 단계는 성공 시 조용하지만, 실패하면 psql의 출력을 그대로 보여 준다.
run_step() { # $1=단계 이름, 나머지=kit_psql 인자. 표준 입력은 그대로 이어진다.
  local step="$1"; shift
  local out
  if ! out=$(kit_psql "$@" 2>&1); then
    [ -z "$out" ] || printf '%s\n' "$out" | sed 's/^/  /' >&2
    if [ "$KIT_MODE" = native ]; then
      fail "world 초기화 실패 ($step) — 데이터베이스 $DB" \
           "먼저 다른 ./verify.sh·./reset.sh 나 열어 둔 psql 세션이 같은 데이터베이스를 쓰고 있지 않은지 확인하세요(겹치면 락이 엉켜 실패합니다 — 끝나길 기다린 뒤 다시). 아니라면 ./check_env.sh 로 접속과 world 상태를 확인하고, 그래도 막히면 dropdb $DB 로 지운 뒤 ./setup.sh 를 실행하면 정렬 규칙을 고정해 다시 만들고 world를 적재합니다"
    else
      fail "world 초기화 실패 ($step) — 컨테이너 $KIT_CONTAINER, 데이터베이스 $DB" \
           "먼저 다른 ./verify.sh·./reset.sh 나 열어 둔 psql 세션이 같은 데이터베이스를 쓰고 있지 않은지 확인하세요(겹치면 락이 엉켜 실패합니다 — 끝나길 기다린 뒤 다시). 아니라면 ./check_env.sh 로 접속과 world 상태를 확인하고, 그래도 막히면 docker rm -f $KIT_CONTAINER 로 컨테이너를 지우고 ./setup.sh 를 실행하세요"
    fi
  fi
}

PSQL_OPTS=(-d "$DB" -X -q -v ON_ERROR_STOP=1)

run_step "스키마 재생성 (public·legacy·antipatterns)" "${PSQL_OPTS[@]}" \
  -c "SET client_min_messages = warning;
      DROP SCHEMA IF EXISTS antipatterns CASCADE;
      DROP SCHEMA IF EXISTS legacy CASCADE;
      DROP SCHEMA public CASCADE;
      CREATE SCHEMA public;"
run_step "schema.sql 적재"       "${PSQL_OPTS[@]}" < schema.sql
run_step "seed_ref.sql 적재"     "${PSQL_OPTS[@]}" < seed_ref.sql
run_step "seed.sql 적재"         "${PSQL_OPTS[@]}" < seed.sql
run_step "seed_ops.sql 생성·적재" "${PSQL_OPTS[@]}" < seed_ops.sql
run_step "legacy.sql 적재"       "${PSQL_OPTS[@]}" < legacy.sql
run_step "antipatterns.sql 적재" "${PSQL_OPTS[@]}" < antipatterns.sql
# 통계를 다시 모은다. page_views 는 schema.sql 이 통계 표본을 전체 행으로 고정해 두었으므로
# 실행 계획의 추정 행 수·비용이 구축마다 같다.
run_step "통계 수집 (ANALYZE)"    "${PSQL_OPTS[@]}" -c "ANALYZE;"
echo "world 초기화 완료 (public: 책숲 운영 world 12테이블 / legacy: 판매 원장 / antipatterns: 안티패턴 조각)"
