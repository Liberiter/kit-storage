#!/usr/bin/env bash
# 환경 검증 = 코스 entry check(입장 점검)의 판정 기준 (0장 0.5절).
# 접속 → 버전 → world 속성(정렬 규칙 · 세션 설정 + world_check.sql) 순으로 확인한다.
# libc 문자 분류(LC_CTYPE)는 판정에 넣지 않고 알림만 낸다 (아래 「world 속성 (2)」).
# 실패하면 원인과 함께 **다음에 무엇을 하면 되는지**를 한 줄로 알린다.
#
# 판정 근거는 entry check의 셋뿐이다 — (a) psql 접속, (b) 서버 메이저
# 버전, (c) world 속성 검증. 정렬 규칙 확인은 (c)에 속한다: 설치 방식이나
# 컨테이너 존재 여부가 아니라 **접속한 데이터베이스의 성질**만 보므로 두
# 경로에서 같은 검사가 같은 기대값으로 돈다.
#
# 두 경로를 모두 통과시킨다 (0장 0.1절 기본 경로·0.7절 대안 경로):
#   기본 경로  ./check_env.sh                (KIT_MODE=docker, 기본값)
#   대안 경로  KIT_MODE=native ./check_env.sh (호스트에 설치한 psql로 접속)
set -euo pipefail
cd "$(dirname "$0")"
# 이 줄도 «셸이» 파일을 읽는 자리다 — 없으면 셸이 먼저 실패하고 kit의 문구가 나올
# 자리가 없다(0장 0.6). fail()·kit_psql 이 아직 없으므로 직접 낸다.
[ -r ./kit_psql.sh ] || {
  echo "entry check 실패: kit 파일 kit_psql.sh 을(를) 읽을 수 없습니다." >&2
  echo "  다음: 파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)." >&2
  exit 1; }
. ./kit_psql.sh

DB="$KIT_DB"

fail() { # $1=원인, $2=다음에 할 일
  echo "entry check 실패: $1" >&2
  [ "${2:-}" = "" ] || echo "  다음: $2" >&2
  exit 1
}

# 경로별 사전 점검 (docker 명령·런타임·컨테이너 / psql 명령) — 공용 함수, 여러 스크립트가
# 같은 분기·같은 문구를 쓴다 (kit_psql.sh 「실행 전 점검」). 세 번째 인자를 빈 문자열로
# 주어 원인 줄 끝의 경로 표시를 붙이지 않는다 — 0장 0.6절 표가 이 스크립트의 원인 줄을
# 표시 없이 인용하고 있다 (reset.sh 쪽은 표시가 붙은 형태로 인용된다).
kit_runtime_check "entry check" 1 ""

# (a) psql 접속 — 공용 함수 (verify.sh도 같은 문구로 멈춘다). 실패 시
# 「entry check 실패: psql 접속 불가 …」와 종료 코드 1.
kit_connect_check "entry check" 1

ver=$(kit_psql -d "$DB" -tAc "SHOW server_version;")
case "$ver" in
  18.*) ;;
  *)
    if [ "$KIT_MODE" = native ]; then
      fail "서버 버전 $ver (기대: 18.x)" \
           "이 코스가 쓰는 메이저는 18입니다. 0장 0.7절대로 PostgreSQL 18을 설치해 접속 정보를 그쪽으로 돌리세요 (여러 버전을 함께 쓴다면 PGPORT로 18 쪽 포트를 지정)"
    else
      fail "서버 버전 $ver (기대: 18.x)" \
           "이 코스가 쓰는 메이저는 18입니다. docker rm -f $KIT_CONTAINER 로 컨테이너를 지운 뒤 ./setup.sh 를 실행하면 postgres:18 이미지로 다시 만듭니다"
    fi
    ;;
esac

# world 속성 (1) — 정렬 규칙(collation).
# 챕터 본문의 표는 한글 ORDER BY의 차례를 그대로 싣는다. 정렬 규칙이 다르면
# 값은 같은데 줄의 차례가 다른 표를 학습자가 보게 된다(9·11·12·13장).
# 기대값과 프로브는 kit_psql.sh에 있다 — setup.sh와 같은 기준을 쓴다.
#
# world_check.sql이 아니라 여기 두는 이유:
#   - world_check.sql은 schema.sql + seed.sql이 만든 **데이터**의 속성(행 수·
#     분포·정합성·제약)을 보는 자리이고, 그 실패의 처방은 `./reset.sh`다.
#     정렬 규칙은 데이터가 아니라 **데이터베이스를 만들 때 정해지는 설정**이라
#     reset으로는 되돌아가지 않는다. 같은 분기에 넣으면 「./reset.sh 로 되돌린
#     뒤 다시 실행하세요」가 **듣지 않는 안내**가 된다 — 처방이 다르므로
#     (dropdb 후 ./setup.sh) 분기를 나눈다.
#   - world 정의 4파일(schema.sql·seed.sql·generate_seed.py·world_check.sql)을
#     건드리지 않는다. 서버 설정을 world 정의에 섞지 않는 것이 옳기도 하다.
sort_now=$(kit_sort_probe "$DB" 2>/dev/null || true)
if [ "$sort_now" != "$KIT_SORT_EXPECTED" ]; then
  echo "  기대한 차례: $KIT_SORT_EXPECTED" >&2
  echo "  실제 차례:   ${sort_now:-(확인 실패)}" >&2
  if [ "$KIT_MODE" = native ]; then
    fail "world 정렬 규칙 불일치 — 데이터베이스 $DB 의 ORDER BY 차례가 교재 본문과 다릅니다" \
         "이 데이터베이스는 다른 로케일로 만들어졌습니다. dropdb $DB 로 지운 뒤 ./setup.sh 를 실행하세요 — 정렬 규칙(C.UTF-8, builtin 제공자)을 고정해 새로 만들고 world를 seed.sql에서 다시 적재하므로 잃는 것이 없습니다"
  else
    fail "world 정렬 규칙 불일치 — 데이터베이스 $DB 의 ORDER BY 차례가 교재 본문과 다릅니다" \
         "컨테이너가 C.UTF-8 로케일로 초기화되지 않았습니다. docker rm -f $KIT_CONTAINER 로 컨테이너를 지운 뒤 ./setup.sh 를 실행하면 LANG=C.UTF-8 로 다시 만듭니다"
  fi
fi

# world 속성 (2) — libc 문자 분류(LC_CTYPE). **판정에 넣지 않는다.** 이 축은 값을 글자
# 단위로 어떻게 읽을지를 정하고 영향을 받는 자리가 넓다 — 확인된 목록과 실측은
# kit_psql.sh 「libc 문자 분류」에 있고 **그것이 전부라고 단정하지 않는다.**
# **이 코스의 출력에서 실제로 갈리는 것은 한 자리뿐이다** — 1장 1.2 의
# ch01-04-list-databases 로, 서버 자신의 사실을 비추는 케이스라 kit 이 이미 경로 축으로
# 세고 있다. 근거는 world 의 문자 구성이 아니라(한글도 갈린다) **이 코스가 정규식·대소문자
# 무시 비교를 한 건도 쓰지 않고, 대소문자 변환을 쓰는 자리의 인자가 모두 ASCII** 라는
# 것이다(cases 465건 전수 — kit_psql.sh 「libc 문자 분류」).
# 옛 kit 으로 이미 만든 데이터베이스를 입장에서 막지 않기 위해, 어긋나면 알림만 낸다.
# 데이터베이스를 만들 때 정해지는 성질이라 ALTER 로는 못 고친다 — 맞추려면 dropdb 뒤 ./setup.sh 다.
ctype_now=$(kit_ctype_probe "$DB" 2>/dev/null || true)
if ! kit_ctype_ok "$ctype_now"; then
  echo "알림: 데이터베이스 $DB 의 문자 분류(LC_CTYPE)가 '${ctype_now:-(확인 실패)}' 입니다 — ./setup.sh 가 새로 만드는 데이터베이스는 $KIT_CTYPE_EXPECTED_TEXT 입니다." >&2
  echo "        이 설정은 값을 글자 단위로 어떻게 읽을지를 정합니다 — 대소문자 변환, 글자 종류 판정 같은 것들이 여기에 딸립니다. 이 코스의 예제와 문제에서 실제로 달라지는 것은 1장 1.2 의 \\l 이 내는 Ctype 열 한 자리이고, 그 줄은 원래 여러분 서버 자신을 비추는 자리입니다. 그래서 입장 점검은 이 항목으로 막지 않습니다." >&2
  echo "        굳이 맞추고 싶으시면 dropdb $DB 로 지운 뒤 ./setup.sh 를 다시 실행하세요 — world 는 seed.sql 에서 다시 적재되므로 잃는 것이 없습니다." >&2
fi

# world 속성 (3) — 세션 시간대·메시지 언어·날짜 표기·로케일(통화·숫자·날짜 이름). 기대값과
# 프로브는 kit_psql.sh에 있다. 정렬 규칙과 마찬가지로 데이터가 아니라 데이터베이스 설정이라
# ./reset.sh 로는 되돌아가지 않는다 — 처방은 ./setup.sh 재실행(설정을 다시 적용한다)이고
# 데이터베이스를 지울 필요는 없다. kit 호출은 전부 -X 라 이 프로브는 여러분의 ~/.psqlrc 를
# 읽지 않는다 (README 「두 경로」).
session_now=$(kit_session_probe "$DB" 2>/dev/null || true)
if [ "$session_now" != "$KIT_SESSION_EXPECTED" ]; then
  echo "  기대한 설정 (timezone|lc_messages|DateStyle|lc_monetary|lc_numeric|lc_time): $KIT_SESSION_EXPECTED" >&2
  echo "  실제 설정:                                                                  ${session_now:-(확인 실패)}" >&2
  if [ "$KIT_MODE" = native ]; then
    fail "world 세션 설정 불일치 — 데이터베이스 $DB 의 시간대·메시지 언어·날짜 표기·로케일이 교재 본문과 다릅니다 (오류 메시지의 언어, 날짜 입력 해석, to_char 의 통화 기호·요일 이름이 달라집니다)" \
         "./setup.sh 를 다시 실행하세요 — 설정을 다시 적용하면서 예제 데이터도 처음 상태로 넣습니다(데이터베이스를 지우지 않습니다). 그래도 같으면 psql 쪽 환경 변수 PGTZ·PGDATESTYLE 이나 ALTER ROLE … SET 으로 둔 역할 설정이 데이터베이스 설정을 덮고 있는지 확인하세요"
  else
    fail "world 세션 설정 불일치 — 데이터베이스 $DB 의 시간대·메시지 언어·날짜 표기·로케일이 교재 본문과 다릅니다 (오류 메시지의 언어, 날짜 입력 해석, to_char 의 통화 기호·요일 이름이 달라집니다)" \
         "./setup.sh 를 다시 실행하세요 — 설정을 다시 적용하면서 예제 데이터도 처음 상태로 넣습니다(컨테이너도 데이터베이스도 지우지 않습니다)"
  fi
fi

# world 속성 (4) — 데이터 (world_check.sql의 W1~W13).
if ! out=$(kit_psql -d "$DB" -X -q -v ON_ERROR_STOP=1 < world_check.sql 2>&1); then
  echo "$out" >&2
  echo "  (위 메시지의 W로 시작하는 번호는 world_check.sql의 검사 번호입니다 — world_check.sql에서 그 번호의 주석을 찾으면 무엇을 보는 검사인지 알 수 있습니다.)" >&2
  if [ "$KIT_MODE" = native ]; then
    fail "world 속성 검증 실패 — world(책숲)의 데이터가 초기 상태와 다릅니다" \
         "./reset.sh 로 world를 초기 상태로 되돌린 뒤 다시 실행하세요. 그래도 실패하면 dropdb $DB 로 데이터베이스를 지운 뒤 ./setup.sh 를 실행하세요 — setup.sh가 정렬 규칙을 고정해 다시 만들고 world를 seed.sql에서 적재합니다 (여기서 createdb로 직접 만들면 로케일이 서버 기본값이 되어 교재와 차례가 다른 표를 보게 됩니다 — 서버에 따라서는 setup.sh 의 정렬 규칙 검사가 그것을 잡습니다)"
  else
    fail "world 속성 검증 실패 — world(책숲)의 데이터가 초기 상태와 다릅니다" \
         "./reset.sh 로 world를 초기 상태로 되돌린 뒤 다시 실행하세요. 그래도 실패하면 docker rm -f $KIT_CONTAINER 로 컨테이너를 지우고 ./setup.sh 를 실행하세요"
  fi
fi

echo "entry check 통과: PostgreSQL $ver, world(책숲) 적재·속성 확인 완료"
