#!/usr/bin/env bash
# world를 초기 상태로 복원한다 (챕터 상태 연속성 수단).
# 모든 챕터는 초기 상태에서 시작한다 — 11·12장 실습, exit assessment,
# 검증 러너의 변경형 케이스 전후에 실행한다.
# 두 경로 모두에서 동작한다: KIT_MODE=docker / KIT_MODE=native.
# KIT_MODE를 지정하지 않으면 setup.sh가 구축에 쓴 경로를 따른다
# (kit_psql.sh 「구축 경로 기억」).
#
# **실패하면 반드시 말한다.** 이 스크립트는 챕터 본문이 맨 명령(`./reset.sh`)으로
# 40곳에서 부르는 자리이고, 11장은 「그래야 책에 실린 결과와 같은 결과가
# 나옵니다」라고 못 박는다. 되돌리기가 실패한 것을 학습자가 모르면 이후 출력이
# 전부 본문과 갈린다. 그래서 성공 시에는 조용하되(한 줄), 실패 시에는 psql의
# 출력을 삼키지 않고 원인 한 줄 + 다음 행동 한 줄을 낸다 — check_env.sh의
# fail() 과 같은 어투다.
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
# 지우고, 서로의 락이 엉켜 world 자체가 깨질 수 있다(실측: bookstore DB 소실).
# 러너 자신이 부르는 reset은 KIT_LOCK_HELD로 알아본다 (kit_psql.sh 「러너 동시 실행 보호」).
lock_owner="$(kit_lock_owner)"
if [ -n "$lock_owner" ] && [ "$lock_owner" != "${KIT_LOCK_HELD:-}" ]; then
  fail "검증 러너(PID $lock_owner)가 같은 world($(kit_lock_target))를 쓰는 중입니다 — 지금 되돌리면 그 실행의 결과가 깨지고 world가 손상될 수 있습니다" \
       "그 실행이 끝난 뒤 다시 실행하세요 (이 터미널에서 돌린 게 아니라면 다른 터미널이나 다른 체크아웃의 ./verify.sh 입니다)" 2
fi

# 경로별 사전 점검 — 여기서 걸리면 psql을 부르기 전에 원인을 특정할 수 있다.
if [ "$KIT_MODE" = native ]; then
  command -v "$KIT_PSQL" >/dev/null 2>&1 \
    || fail "psql 명령 없음 ($KIT_PSQL)" \
            "environment.md 「학습자 로컬 환경 요구사항」의 대안 경로대로 PostgreSQL 18을 설치하고 psql이 PATH에 있는지 확인하세요 (설치했는데 안 잡히면 KIT_PSQL=/설치경로/psql 로 지정)"
else
  command -v docker >/dev/null 2>&1 \
    || fail "docker 명령 없음 (기본 경로로 실행 중)" \
            "environment.md 「학습자 로컬 환경 요구사항」의 기본 경로대로 런타임을 설치하세요 (Windows: Docker Desktop / macOS: OrbStack / Linux: Docker Engine). 대안 경로(네이티브 설치)로 준비하셨다면 KIT_MODE=native ./setup.sh 를 한 번 실행하세요 — 그 뒤로는 ./reset.sh 를 그대로 쓰시면 됩니다"
  docker ps --format '{{.Names}}' | grep -qx "$KIT_CONTAINER" \
    || fail "컨테이너($KIT_CONTAINER) 미실행 (기본 경로로 실행 중)" \
            "./setup.sh 를 먼저 실행하세요. 대안 경로(네이티브 설치)로 준비하셨다면 KIT_MODE=native ./setup.sh 를 한 번 실행하세요 — 그 뒤로는 ./reset.sh 를 그대로 쓰시면 됩니다"
fi

# 아래 세 단계는 성공 시 조용하지만, 실패하면 psql의 출력을 그대로 보여 준다.
run_step() { # $1=단계 이름, 나머지=kit_psql 인자. 표준 입력은 그대로 이어진다.
  local step="$1"; shift
  local out
  if ! out=$(kit_psql "$@" 2>&1); then
    [ -z "$out" ] || printf '%s\n' "$out" | sed 's/^/  /' >&2
    if [ "$KIT_MODE" = native ]; then
      fail "world 초기화 실패 ($step) — 데이터베이스 $DB" \
           "먼저 다른 ./verify.sh·./reset.sh 나 열어 둔 psql 세션이 같은 데이터베이스를 쓰고 있지 않은지 확인하세요(겹치면 락이 엉켜 실패합니다 — 끝나길 기다린 뒤 다시). 아니라면 ./check_env.sh 로 접속과 world 상태를 확인하고, 그래도 막히면 dropdb $DB 로 지운 뒤 ./setup.sh 를 실행하면 정렬 규칙을 고정해 다시 만들고 world를 seed.sql에서 적재합니다"
    else
      fail "world 초기화 실패 ($step) — 컨테이너 $KIT_CONTAINER, 데이터베이스 $DB" \
           "먼저 다른 ./verify.sh·./reset.sh 나 열어 둔 psql 세션이 같은 데이터베이스를 쓰고 있지 않은지 확인하세요(겹치면 락이 엉켜 실패합니다 — 끝나길 기다린 뒤 다시). 아니라면 ./check_env.sh 로 접속과 world 상태를 확인하고, 그래도 막히면 docker rm -f $KIT_CONTAINER 로 컨테이너를 지우고 ./setup.sh 를 실행하세요"
    fi
  fi
}

run_step "public 스키마 재생성" -d "$DB" -X -q -v ON_ERROR_STOP=1 \
  -c "SET client_min_messages = warning; DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
run_step "schema.sql 적재" -d "$DB" -X -q -v ON_ERROR_STOP=1 < schema.sql
run_step "seed.sql 적재"   -d "$DB" -X -q -v ON_ERROR_STOP=1 < seed.sql
echo "world 초기화 완료 (schema.sql + seed.sql)"
