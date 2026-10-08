#!/usr/bin/env bash
# 환경 확인 — 접속 → 버전 → psql 문구 언어 → world 속성(정렬 규칙 + 세션 설정 + 관찰 도구 + world 원본
# + world_check.sql) 순으로 확인한다. libc 문자 분류(LC_CTYPE)와 공유 버퍼 크기(shared_buffers)는
# 사이에서 **알림만** 내고 판정에는 넣지 않는다.
# 입장 점검(entry check)의 첫 단계다: ./entry_check.sh 가 이것을 먼저 부르고, 통과하면
# 4문을 채점한다 (0장 0.5절). 실패하면 원인과 함께 **다음에 무엇을 하면 되는지**를
# 한 줄로 알린다.
#
# 판정하는 것은 셋이다 — (a) psql 접속, (b) 서버 메이저 버전, (c) world 속성.
# (c)는 설치 방식이 아니라 **접속한 서버와 데이터베이스의 성질**만 보므로 두 경로에서 같은 검사가
# 같은 기대값으로 돈다: 정렬 규칙, 세션 설정(시간대·메시지 언어·날짜 표기·로케일·실수 표시 자릿수·
# 실행 계획을 가르는 설정 — 목록은 kit_psql.sh 「세션 설정」), pg_stat_statements 가 서버에 올라와
# 있는가, world 원본이 있는가(없으면 ./reset.sh 가 되돌리지 못한다), 데이터 검사(world_check.sql).
# psql 문구 언어 확인은 (a)에 속한다 — 접속에 쓰는 psql 자신이 교재와 같은 문구로 답하는지를 본다.
#
# 두 경로를 모두 통과시킨다 (0장 0.1절 기본 경로·0.7절 대안 경로):
#   기본 경로  ./check_env.sh                (KIT_MODE=docker, 기본값)
#   대안 경로  KIT_MODE=native ./check_env.sh (호스트에 설치한 psql로 접속)
# 이 스크립트는 bash 로 돈다 — bash 가 아닌 셸(dash 등)로 부르면 셸 자신의 오류로 끝나 kit 의 안내가 나올
# 자리가 없으므로, 먼저 확인하고 거절한다. (macOS 의 sh 는 POSIX 모드의 bash 라 그대로 돈다.)
if [ -z "${BASH_VERSION:-}" ]; then
  echo "환경 확인 실패: 이 스크립트는 bash가 필요합니다 — 지금 셸은 bash가 아니라 확인을 시작하지 않았습니다." >&2
  echo "  다음: ./check_env.sh 또는 bash check_env.sh 로 실행하세요." >&2
  exit 2
fi
set -euo pipefail
cd "$(dirname "$0")"
# 이 줄도 «셸이» 파일을 읽는 자리다 — 없으면 셸이 먼저 실패하고 kit의 문구가 나올
# 자리가 없다(0장 0.6). fail()·kit_psql 이 아직 없으므로 직접 낸다.
[ -r ./kit_psql.sh ] || {
  echo "환경 확인 실패: kit 파일 kit_psql.sh 을(를) 읽을 수 없습니다." >&2
  echo "  다음: 파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)." >&2
  exit 1; }
. ./kit_psql.sh

DB="$KIT_DB"

fail() { # $1=원인, $2=다음에 할 일
  echo "환경 확인 실패: $1" >&2
  [ "${2:-}" = "" ] || echo "  다음: $2" >&2
  exit 1
}

# 경로별 사전 점검 (docker 명령·런타임·컨테이너 / psql 명령) — 공용 함수, 여러 스크립트가 같은 문구
kit_runtime_check "환경 확인"

# (a) psql 접속 — 공용 함수. 실패 시 「환경 확인 실패: psql 접속 불가 …」 rc 1.
kit_connect_check "환경 확인"

ver=$(kit_psql -d "$DB" -tAc "SHOW server_version;")
case "$ver" in
  18.*) ;;
  *)
    if [ "$KIT_MODE" = native ]; then
      fail "서버 버전 $ver (기대: 18.x)" \
           "이 코스가 쓰는 메이저는 18입니다. 0장 0.7절대로 PostgreSQL 18을 설치해 접속 정보를 그쪽으로 돌리세요 (여러 버전을 함께 쓴다면 PGPORT로 18 쪽 포트를 지정)"
    else
      fail "서버 버전 $ver (기대: 18.x)" \
           "이 코스가 쓰는 메이저는 18입니다. docker rm -fv $KIT_CONTAINER 로 컨테이너를 지운 뒤 ./setup.sh 를 실행하면 postgres:18 이미지로 다시 만듭니다"
    fi
    ;;
esac

# psql 클라이언트 문구의 언어 — 서버 설정이 아니라 kit 이 부르는 psql 자신의 성질이다
# (kit_psql.sh kit_psql_native·kit_client_probe). 실패하면 고정이 먹지 않는 psql 이다 — 러너·입장 점검의
# 대조가 전량 어긋난다. 여러분이 직접 여는 psql 의 언어는 판정하지 않는다 (README 「두 경로」).
client_now=$(kit_client_probe "$DB" || true)
if [ "$client_now" != "$KIT_CLIENT_EXPECTED" ]; then
  echo "  기대한 행 수 줄: $KIT_CLIENT_EXPECTED" >&2
  echo "  실제 행 수 줄:   ${client_now:-(확인 실패)}" >&2
  if [ "$KIT_MODE" = native ]; then
    fail "psql 문구 언어 불일치 — kit 이 부르는 psql($KIT_PSQL)이 교재 본문과 다른 언어로 결과를 냅니다" \
         "kit 은 psql 을 LC_ALL=C.UTF-8 로 불러 영어 문구를 받도록 고정합니다. 그런데도 이렇게 나오면 KIT_PSQL 이 가리키는 것이 스스로 언어를 정하는 감싼 스크립트일 수 있습니다 — PostgreSQL 18 이 설치한 psql 실행 파일을 KIT_PSQL=/설치경로/psql 로 가리킨 뒤 다시 실행하세요"
  else
    fail "psql 문구 언어 불일치 — 컨테이너 $KIT_CONTAINER 안의 psql 이 교재 본문과 다른 언어로 결과를 냅니다" \
         "docker rm -fv $KIT_CONTAINER 로 컨테이너를 지운 뒤 ./setup.sh 를 실행하세요 — kit 이 정한 로케일(LANG=C.UTF-8)로 컨테이너를 다시 만들고 world를 다시 만듭니다"
  fi
fi

# world 속성 (1) — 정렬 규칙(collation). 데이터가 아니라 데이터베이스를 만들 때 정해지는 성질이라
# ./reset.sh 로는 바뀌지 않는다(복제가 원본의 값을 물려받는다) — 처방은 원본을 다시 만드는 것이다.
sort_now=$(kit_sort_probe "$DB" 2>/dev/null || true)
if [ "$sort_now" != "$KIT_SORT_EXPECTED" ]; then
  echo "  기대한 차례: $KIT_SORT_EXPECTED" >&2
  echo "  실제 차례:   ${sort_now:-(확인 실패)}" >&2
  if [ "$KIT_MODE" = native ]; then
    fail "world 정렬 규칙 불일치 — 데이터베이스 $DB 의 ORDER BY 차례가 교재 본문과 다릅니다" \
         "world 원본이 다른 로케일로 만들어졌습니다. dropdb $KIT_TEMPLATE_DB 로 원본을 지운 뒤 ./setup.sh 를 실행하세요 — 정렬 규칙(C.UTF-8, builtin 제공자)을 고정해 원본과 world 를 다시 만듭니다"
  else
    fail "world 정렬 규칙 불일치 — 데이터베이스 $DB 의 ORDER BY 차례가 교재 본문과 다릅니다" \
         "world 원본이 다른 로케일로 만들어졌습니다. docker rm -fv $KIT_CONTAINER 로 컨테이너를 지운 뒤 ./setup.sh 를 실행하세요 — 정렬 규칙을 고정해 원본과 world 를 다시 만듭니다"
  fi
fi

# world 속성 (2) — libc 문자 분류(LC_CTYPE). **판정에 넣지 않는다** (kit_psql.sh 「libc 문자 분류」).
ctype_now=$(kit_ctype_probe "$DB" 2>/dev/null || true)
if ! kit_ctype_ok "$ctype_now"; then
  echo "알림: 데이터베이스 $DB 의 문자 분류(LC_CTYPE)가 '${ctype_now:-(확인 실패)}' 입니다 — ./setup.sh 가 새로 만드는 원본은 $KIT_CTYPE_EXPECTED_TEXT 입니다." >&2
  echo "        이 설정은 값을 글자 단위로 어떻게 읽을지를 정합니다. 행 전체를 한 값으로 찍는 출력(ROW(…)::text 같은 것)과 \\l 이 내는 Ctype 열이 교재와 다르게 보일 수 있지만, 환경 확인은 이 항목으로 막지 않습니다." >&2
  echo "        맞추고 싶으시면 원본을 지운 뒤(대안 경로: dropdb $KIT_TEMPLATE_DB / 기본 경로: docker rm -fv $KIT_CONTAINER) ./setup.sh 를 다시 실행하세요." >&2
fi

# kit 점검 밖의 축 — 대안 경로에서 psqlrc 가 여러분의 psql 세션 설정을 바꾸면 알림만 낸다
# (판정·종료 코드 불변). 세션 설정 판정 **앞**에 두어, 아래 판정이 실패해 멈추는 경우에도 알림이 먼저 보인다.
kit_psqlrc_warn

# world 속성 (3) — 세션 설정 (kit_psql.sh 「세션 설정」). 데이터가 아니라 데이터베이스 설정이다 —
# ./reset.sh 가 복제할 때마다 다시 걸므로 처방은 ./reset.sh 다.
session_now=$(kit_session_probe "$DB" 2>/dev/null || true)
if [ "$session_now" != "$KIT_SESSION_EXPECTED" ]; then
  echo "  설정 ($KIT_SESSION_NAMES)" >&2
  echo "  기대: $KIT_SESSION_EXPECTED" >&2
  echo "  실제: ${session_now:-(확인 실패)}" >&2
  if [ "$KIT_MODE" = native ]; then
    fail "world 세션 설정 불일치 — 데이터베이스 $DB 의 시간대·메시지 언어·날짜 표기·로케일·실수 표시 자릿수·실행 계획 설정이 교재 본문과 다릅니다" \
         "./reset.sh 를 실행하세요 — world 를 다시 만들면서 설정을 다시 겁니다. 그래도 같으면 psql 쪽 환경 변수 PGTZ·PGDATESTYLE·PGOPTIONS 나 ALTER ROLE … SET 으로 둔 역할 설정이 데이터베이스 설정을 덮고 있는지 확인하세요 (psqlrc 는 이 점검이 읽지 않으므로 여기의 원인이 아닙니다 — psqlrc 가 여러분 세션을 바꾸는 경우에는 위에 「알림:」이 따로 나옵니다)"
  else
    fail "world 세션 설정 불일치 — 데이터베이스 $DB 의 시간대·메시지 언어·날짜 표기·로케일·실수 표시 자릿수·실행 계획 설정이 교재 본문과 다릅니다" \
         "./reset.sh 를 실행하세요 — world 를 다시 만들면서 설정을 다시 겁니다. 그래도 같으면 ALTER ROLE … SET 으로 둔 역할 설정이 데이터베이스 설정을 덮고 있는지 확인하세요"
  fi
fi

# world 속성 (4) — 관찰 도구: pg_stat_statements 가 서버에 올라와 있는가 (kit_psql.sh 「관찰 도구」).
if ! kit_preload_ok "$DB"; then
  if [ "$KIT_MODE" = native ]; then
    fail "pg_stat_statements 가 서버에 올라와 있지 않습니다 — 1장부터 쓰는 질의 측정 도구입니다" \
         "KIT_MODE=native ./setup.sh 를 실행하세요 — 서버 설정에 무엇을 더하고 서버를 어떻게 다시 시작하는지 안내합니다"
  else
    fail "pg_stat_statements 가 컨테이너 $KIT_CONTAINER 의 서버에 올라와 있지 않습니다 — 이 kit 이 만든 컨테이너가 아닙니다" \
         "docker rm -fv $KIT_CONTAINER 로 컨테이너를 지운 뒤 ./setup.sh 를 실행하면 이 코스의 설정으로 다시 만듭니다"
  fi
fi

# world 속성 (5) — world 원본. 없으면 ./reset.sh 가 world 를 되돌리지 못한다.
kit_template_exists \
  || fail "world 원본 데이터베이스($KIT_TEMPLATE_DB)가 없습니다 — 지금 world 는 쓸 수 있어도 ./reset.sh 로 되돌릴 수 없습니다" \
          "./setup.sh 를 실행하세요 — 원본을 다시 만듭니다 (1분 안팎)"

# 공유 버퍼 크기 — 서버를 시작할 때 정해져 kit 이 데이터베이스 설정으로 못 박지 못한다. 판정이 아니라 알림이다.
sb_now=$(kit_shared_buffers_probe "$DB" 2>/dev/null || true)
if [ "$sb_now" != "$KIT_SHARED_BUFFERS_EXPECTED" ]; then
  echo "알림: 서버의 공유 버퍼 크기(shared_buffers)가 '${sb_now:-(확인 실패)}' 입니다 — 교재는 $KIT_SHARED_BUFFERS_EXPECTED(PostgreSQL 기본값)에서 받은 화면을 싣습니다." >&2
  echo "        실행 계획의 Buffers 줄(공유 버퍼에서 찾은 블록 hit 과 밖에서 읽어 온 블록 read 의 수)과 일부 계획이 교재와 다르게 나올 수 있지만, 환경 확인은 이 항목으로 막지 않습니다." >&2
  echo "        맞추고 싶으시면 서버 설정의 shared_buffers 를 $KIT_SHARED_BUFFERS_EXPECTED 로 두고 서버를 다시 시작하세요." >&2
fi

# world 속성 (6) — 데이터 (world_check.sql).
# 입력 리디렉션(`< world_check.sql`)은 «셸이» 파일을 읽는 자리다 — 파일이 없으면 psql 이 돌기도 전에
# 셸이 실패하고, 그 실패가 아래 갈래에서 「world 속성 검증 실패 … ./reset.sh」로 읽혀 원인과 다른 처방이
# 나온다. 그래서 읽기 전에 먼저 확인한다 (reset.sh·setup.sh 의 같은 가드와 같은 문구).
[ -r world_check.sql ] || fail "kit 파일 world_check.sql 을(를) 읽을 수 없습니다" \
                              "파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)"
if ! out=$(kit_psql -d "$DB" -X -q -v ON_ERROR_STOP=1 < world_check.sql 2>&1); then
  echo "$out" >&2
  echo "  (위 메시지의 W로 시작하는 번호는 world_check.sql의 검사 번호입니다 — world_check.sql에서 그 번호의 주석을 찾으면 무엇을 보는 검사인지 알 수 있습니다.)" >&2
  fail "world 속성 검증 실패 — world(책숲 대규모 운영 데이터)가 초기 상태와 다릅니다" \
       "./reset.sh 로 world를 초기 상태로 되돌린 뒤 다시 실행하세요. 그래도 실패하면 ./setup.sh 를 실행하세요 — 원본이 지금 kit 파일과 다르면 원본부터 다시 만듭니다"
fi

echo "환경 확인 통과: PostgreSQL $ver, world(책숲 대규모 운영 데이터) 적재·속성 확인 완료"
