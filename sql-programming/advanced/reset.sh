#!/usr/bin/env bash
# world를 초기 상태로 복원한다 (챕터 상태 연속성 수단).
# 모든 챕터는 초기 상태에서 시작한다 — world를 바꾸는 실습의 전후, 그리고 검증 러너의 변경형
# 케이스와 두 세션 재현(sessions.sh)의 전후에 실행한다.
# 두 경로 모두에서 동작한다: KIT_MODE=docker / KIT_MODE=native.
# KIT_MODE를 지정하지 않으면 setup.sh가 구축에 쓴 경로를 따른다 (kit_psql.sh 「구축 경로 기억」).
#
# 되돌리는 방법: world 데이터베이스(bookstore_scale)를 **통째로** 지우고, setup.sh 가 만들어 둔
# 원본(bookstore_scale_template)을 파일째 복제해 다시 만든다 (kit_psql.sh 「world 원본」). 1~3초.
# 그래서 이 데이터베이스 안에 여러분이 만든 것은 스키마와 무관하게 모두 사라진다 — 남겨 두려면
# 다른 데이터베이스에 만드세요.
#
# **이 데이터베이스에 붙어 있는 세션은 끊는다** (DROP DATABASE … WITH (FORCE)). 다른 터미널에 열어
# 둔 psql 은 다음 명령에서 연결이 끊겼다는 메시지를 한 번 내고 스스로 다시 붙는다 — 그 명령은 실행되지
# 않으므로 한 번 더 입력하면 된다. 열려 있던 트랜잭션은 끝나지 않은 채 사라진다(되돌리기가 하려던
# 일과 같다). 끊은 세션이 있으면 몇 개였는지 알림 한 줄을 낸다.
#
# **실패하면 반드시 말한다.** 되돌리기가 실패한 것을 모르면 이후 출력이 전부 본문과
# 갈린다. 성공 시에는 조용하되(한 줄), 실패 시에는 psql의 출력을 삼키지 않고 원인 한 줄
# + 다음 행동 한 줄을 낸다.
# 이 스크립트는 bash 로 돈다 — bash 가 아닌 셸(dash 등)로 부르면 셸 자신의 오류로 끝나 kit 의 안내가 나올
# 자리가 없으므로, 먼저 확인하고 거절한다. (macOS 의 sh 는 POSIX 모드의 bash 라 그대로 돈다.)
if [ -z "${BASH_VERSION:-}" ]; then
  echo "reset 실패: 이 스크립트는 bash가 필요합니다 — 지금 셸은 bash가 아니라 되돌리기를 시작하지 않았습니다." >&2
  echo "  다음: ./reset.sh 또는 bash reset.sh 로 실행하세요." >&2
  exit 2
fi
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
TEMPLATE="$KIT_TEMPLATE_DB"
ADMIN="$KIT_ADMIN_DB"

fail() { # $1=원인, $2=다음에 할 일, $3=종료 코드(기본 1)
  echo "reset 실패: $1" >&2
  [ "${2:-}" = "" ] || echo "  다음: $2" >&2
  exit "${3:-1}"
}

# 검증 러너 같은 실행이 이 world를 쓰는 동안에는 되돌리지 않는다 — 그 실행의 전제 상태를 지운다.
# 그 실행 자신이 부르는 reset은 KIT_LOCK_HELD로 알아본다 (kit_psql.sh 「러너 동시 실행 보호」).
lock_owner="$(kit_lock_owner)"
if [ -n "$lock_owner" ] && [ "$lock_owner" != "${KIT_LOCK_HELD:-}" ]; then
  fail "같은 world($(kit_lock_target))를 쓰는 다른 실행(PID $lock_owner)이 있습니다 — 지금 되돌리면 그 실행의 결과가 깨집니다" \
       "그 실행이 끝난 뒤 다시 실행하세요 (이 터미널에서 돌린 게 아니라면 다른 터미널이나 다른 폴더에 받아 둔 kit의 ./verify.sh·./entry_check.sh·./sessions.sh·./measure.sh·./workload.sh 입니다)" 2
fi

# 경로별 사전 점검 — 여기서 걸리면 psql을 부르기 전에 원인을 특정할 수 있다.
kit_runtime_check "reset"

if ! kit_psql -d "$ADMIN" -tAc "SELECT 1" >/dev/null 2>&1; then
  if [ "$KIT_MODE" = native ]; then
    fail "PostgreSQL 서버에 접속하지 못했습니다 (관리용 데이터베이스 $ADMIN)" \
         "서버가 떠 있는지(macOS Homebrew는 brew services start postgresql@18, Linux·WSL2는 sudo systemctl start postgresql)와 접속 정보(PGHOST·PGPORT·PGUSER·PGPASSWORD)를 확인한 뒤 다시 실행하세요. 관리용 데이터베이스 이름이 postgres가 아니면 KIT_ADMIN_DB로 지정하세요"
  else
    fail "서버에 접속하지 못했습니다 (컨테이너 $KIT_CONTAINER)" \
         "docker logs $KIT_CONTAINER 로 서버 상태를 본 뒤 ./setup.sh 를 다시 실행하세요"
  fi
fi

kit_template_exists \
  || fail "world 원본 데이터베이스($TEMPLATE)가 없습니다 — 되돌릴 원본이 없습니다" \
          "./setup.sh 를 실행하세요 — 원본을 만들고 world 를 초기 상태로 세웁니다 (1분 안팎)"

# 아래 단계는 성공 시 조용하지만, 실패하면 psql의 출력을 그대로 보여 준다.
run_step() { # $1=단계 이름, 나머지=kit_psql 인자
  local step="$1"; shift
  local out
  if ! out=$(kit_psql "$@" 2>&1); then
    [ -z "$out" ] || printf '%s\n' "$out" | sed 's/^/  /' >&2
    fail "world 초기화 실패 ($step) — 데이터베이스 $DB" \
         "먼저 다른 ./verify.sh·./reset.sh·./sessions.sh 가 같은 world를 쓰고 있지 않은지 확인하세요(겹치면 실패합니다 — 끝나길 기다린 뒤 다시). 아니라면 ./reset.sh 를 한 번 더 실행하고, 그래도 막히면 ./setup.sh 로 원본과 world 를 다시 세우세요. 대안 경로에서 위 메시지가 소유주·권한을 말하면 슈퍼유저로 접속하도록 PGUSER 를 바꿔 다시 실행하세요 (예: PGUSER=postgres ./reset.sh)"
  fi
}

# 끊을 세션 수 — 알림에만 쓴다 (세지 못해도 되돌리기는 그대로 한다).
others=$(kit_psql -d "$ADMIN" -tAc "SELECT count(*) FROM pg_stat_activity WHERE datname = '$DB' AND pid <> pg_backend_pid()" 2>/dev/null || echo 0)

run_step "world 데이터베이스 지우기" -d "$ADMIN" -q -v ON_ERROR_STOP=1 \
  -c "DROP DATABASE IF EXISTS \"$DB\" WITH (FORCE)"
# FILE_COPY 는 원본의 파일을 운영체제 수준에서 그대로 복사한다 — 기본 방법(WAL_LOG)은 수백 MB 를
# 공유 버퍼를 거쳐 한 페이지씩 옮기며 그 일부를 버퍼에 남겨, 되돌린 직후의 «공유 버퍼에 무엇이
# 있는가»가 그때그때 달라진다. FILE_COPY 로 만든 world 는 공유 버퍼에 한 페이지도 없는 상태로 시작한다.
run_step "world 데이터베이스 복제" -d "$ADMIN" -q -v ON_ERROR_STOP=1 \
  -c "CREATE DATABASE \"$DB\" TEMPLATE \"$TEMPLATE\" STRATEGY FILE_COPY"
if ! out=$(kit_session_fix "$DB" 2>&1); then
  [ -z "$out" ] || printf '%s\n' "$out" | sed 's/^/  /' >&2
  fail "world 데이터베이스 $DB 의 세션 설정을 고정하지 못했습니다 (권한 문제일 수 있습니다)" \
       "슈퍼유저로 접속하도록 PGUSER 를 바꿔 다시 실행하세요 (예: PGUSER=postgres ./reset.sh). 기본 경로라면 ./setup.sh 를 다시 실행하세요"
fi

case "$others" in ''|*[!0-9]*) others=0 ;; esac
if [ "$others" -gt 0 ]; then
  echo "알림: world 데이터베이스에 붙어 있던 세션 ${others}개를 끊었습니다 — 그 psql 에서는 다음 명령이 한 번 실패한 뒤 스스로 다시 붙습니다(그 명령은 한 번 더 입력하세요)." >&2
fi
echo "world 초기화 완료 ($DB — 원본 $TEMPLATE 에서 복제)"
