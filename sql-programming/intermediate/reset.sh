#!/usr/bin/env bash
# world를 초기 상태로 복원한다 (챕터 상태 연속성 수단).
# 모든 챕터는 초기 상태에서 시작한다 — world를 바꾸는 실습(6·7·8·10·11·12장, 9장의 두 실습, 마지막 평가 장)의
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
# 이 줄도 «셸이» 파일을 읽는 자리다 — 없으면 셸이 먼저 실패하고 kit의 문구가 나올
# 자리가 없다(0장 0.6). fail()·kit_psql 이 아직 없으므로 직접 낸다.
[ -r ./kit_psql.sh ] || {
  echo "reset 실패: kit 파일 kit_psql.sh 을(를) 읽을 수 없습니다." >&2
  echo "  다음: 파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)." >&2
  exit 1; }
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
  fail "같은 world($(kit_lock_target))를 쓰는 다른 실행(PID $lock_owner)이 있습니다 — 지금 되돌리면 그 실행의 결과가 깨지고 world가 손상될 수 있습니다" \
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
           "먼저 다른 ./verify.sh·./reset.sh 나 열어 둔 psql 세션이 같은 데이터베이스를 쓰고 있지 않은지 확인하세요(겹치면 락이 엉켜 실패합니다 — 끝나길 기다린 뒤 다시. 트랜잭션을 연 채인 psql 세션이나 ./concurrency.sh --terminal 의 두 터미널 세션이면 그 세션에서 ROLLBACK; 또는 \q 한 뒤 다시). 아니라면 ./check_env.sh 로 접속과 world 상태를 확인하고, 그래도 막히면 dropdb $DB 로 지운 뒤 ./setup.sh 를 실행하면 정렬 규칙을 고정해 다시 만들고 world를 적재합니다"
    else
      fail "world 초기화 실패 ($step) — 컨테이너 $KIT_CONTAINER, 데이터베이스 $DB" \
           "먼저 다른 ./verify.sh·./reset.sh 나 열어 둔 psql 세션이 같은 데이터베이스를 쓰고 있지 않은지 확인하세요(겹치면 락이 엉켜 실패합니다 — 끝나길 기다린 뒤 다시. 트랜잭션을 연 채인 psql 세션이나 ./concurrency.sh --terminal 의 두 터미널 세션이면 그 세션에서 ROLLBACK; 또는 \q 한 뒤 다시). 아니라면 ./check_env.sh 로 접속과 world 상태를 확인하고, 그래도 막히면 docker rm -f $KIT_CONTAINER 로 컨테이너를 지우고 ./setup.sh 를 실행하세요"
    fi
  fi
}

PSQL_OPTS=(-d "$DB" -X -q -v ON_ERROR_STOP=1)

# 적재는 셸의 입력 리디렉션(`< 파일`)으로 파일을 읽는데, 리디렉션은 run_step 이
# 돌기 전에 «셸이» 처리한다. 파일이 없으면 셸이 거기서 실패하고 set -e 가 스크립트를
# 끝내므로 kit의 문구가 나올 자리가 없다 (0장 0.6이 「원인 줄과 다음: 안내를 내고
# 멈춥니다」라고 적는 자리다). 그래서 읽기 전에 먼저 확인한다 — world를 지우기
# «전에» 본다. 지운 뒤에 걸리면 되돌릴 것이 없는 채로 멈춘다.
for _f in schema.sql seed_ref.sql seed.sql seed_ops.sql legacy.sql antipatterns.sql; do
  [ -r "$_f" ] || fail "kit 파일 $_f 을(를) 읽을 수 없습니다" \
                       "파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)"
done

# 첫 단계에만 잠금 대기 시한을 둔다. 여러분이 다른 psql 세션에서 트랜잭션을 연 채(BEGIN 뒤 world 의
# 테이블을 읽거나 고친 채) 되돌리면, DROP SCHEMA 가 그 트랜잭션이 끝날 때까지 기다려 이 스크립트가
# 아무 말 없이 멈춘 것처럼 보인다(12장 두 터미널 실습에서 흔한 자리). 시한(5초)이 지나면 서버가 이
# 문장을 «잠금 시한 초과»로 취소한다. 아래 -c 의 문장들은 한 트랜잭션으로 가므로 취소되면 DROP 전체가
# 없던 일이 되어 world 는 그대로이고, run_step 이 원인과 「다음:」을 낸다. 지운 뒤의 적재 단계는 방금
# 만든 객체만 건드리므로 남의 잠금을 기다릴 일이 없어 시한을 두지 않는다.
run_step "스키마 재생성 (public·legacy·antipatterns)" "${PSQL_OPTS[@]}" \
  -c "SET client_min_messages = warning;
      SET lock_timeout = '5s';
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
# 뒷정리(VACUUM)를 하고 통계를 다시 모은다. page_views 는 schema.sql 이 통계 표본을 전체 행으로
# 고정해 두었으므로 실행 계획의 추정 행 수·비용이 구축마다 같다.
# VACUUM 은 가시성 맵(visibility map)을 채운다. 이것을 건너뛰면 적재 직후에는 맵이 비어 있다가
# 1분쯤 뒤 자동 뒷정리(autovacuum)가 채우므로, Index Only Scan 이 후보인 질의의 실행 계획이
# 되돌린 직후와 조금 지난 뒤에 달라진다. 여기서 채워 두면 되돌린 직후부터 계획이 같다.
# (VACUUM 은 트랜잭션 블록 안에서 돌 수 없다 — psql -c 의 한 문장으로 보낸다.)
run_step "뒷정리·통계 수집 (VACUUM ANALYZE)" "${PSQL_OPTS[@]}" -c "VACUUM (ANALYZE);"
echo "world 초기화 완료 (public: 책숲 운영 world 12테이블 / legacy: 판매 원장 / antipatterns: 안티패턴 조각)"
