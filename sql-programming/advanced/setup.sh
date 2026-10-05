#!/usr/bin/env bash
# 학습 환경 구축: postgres:18 컨테이너 기동 + world(책숲 대규모 운영 데이터) 원본 만들기 + world 복제 + 환경 확인.
# 전제: Docker 호환 런타임 (0장 0.1절 — Windows: Docker Desktop,
#       macOS: OrbStack, Linux: Docker Engine). 그 외 수작업 불필요.
#
# 앞 코스들의 컨테이너(ll-sql-fundamentals 54321, ll-sql-intermediate 54322)는 건드리지 않는다 —
# 이 코스는 ll-sql-advanced(포트 54323)를 따로 만든다. 나란히 두고 써도 된다.
#
# 대안 경로(0장 0.7절 — 직접 설치)는 KIT_MODE=native ./setup.sh.
# 이 경로에서는 컨테이너를 만들 것이 없으므로, 대신 설치하신 서버가 코스에 쓸 수 있는
# 상태인지 점검하고(버전 18, 슈퍼유저 접속, pg_stat_statements 를 올려 둔 서버), world 를 담을
# 원본 데이터베이스(bookstore_scale_template)를 만든다. 원본은 두 경로가 **같은 문장으로** 만든다 —
# 정렬 규칙과 문자 분류까지 같다 (아래 template_build).
#
# world 는 두 데이터베이스로 산다 (kit_psql.sh 「world 원본」):
#   bookstore_scale_template  원본 — 이 스크립트가 kit 파일로 한 번 만들고 접속을 막아 둔다
#   bookstore_scale           여러분이 쓰는 world — ./reset.sh 가 원본을 복제해 다시 만든다
# 원본을 만드는 데는 1분 안팎이 걸린다(판매 150만 건 등을 만들고 뒷정리·통계 수집까지). 이미 원본이
# 있고 지금 kit 파일로 만든 것이면 다시 만들지 않는다 — 컴퓨터를 껐다 켠 뒤의 ./setup.sh 는 몇 초다.
#
# 두 경로 모두 world 데이터베이스의 세션 설정(시간대·메시지 언어·날짜 표기·로케일·실수 표시 자릿수와
# 실행 계획을 가르는 설정)을 ALTER DATABASE 로 못 박는다 — 값과 이유는 kit_psql.sh 「세션 설정」.
# 복제로 새로 만든 데이터베이스에는 그 설정이 따라오지 않으므로 reset.sh 가 복제할 때마다 다시 건다.
#
# 입장 점검의 답을 적는 파일(entry/q1.sql ~ q4.sql)은 배포에 들어 있지 않다. 이 스크립트가
# entry/templates/ 의 문항 파일을 복사해 만들고, **이미 있으면 손대지 않는다** — 재구축이
# 여러분이 적어 두신 답을 지우면 안 되기 때문이다. 되돌리기(reset.sh)도 이 파일들을 보지 않는다.
#
# 구축에 성공하면 **어느 경로로 구축했는지를 상태 파일에 적는다**
# (kit_state_save — 정의와 이유는 kit_psql.sh 「구축 경로 기억」).
# 이 스크립트는 bash 로 돈다 — bash 가 아닌 셸(dash 등)로 부르면 셸 자신의 오류로 끝나 kit 의 안내가 나올
# 자리가 없으므로, 먼저 확인하고 거절한다. (macOS 의 sh 는 POSIX 모드의 bash 라 그대로 돈다.)
if [ -z "${BASH_VERSION:-}" ]; then
  echo "오류: 이 스크립트는 bash가 필요합니다 — 지금 셸은 bash가 아니라 구축을 시작하지 않았습니다." >&2
  echo "  다음: ./setup.sh 또는 bash setup.sh 로 실행하세요." >&2
  exit 2
fi
set -euo pipefail
cd "$(dirname "$0")"
# 이 줄도 «셸이» 파일을 읽는 자리다 — 없으면 셸이 먼저 실패하고 kit의 문구가 나올
# 자리가 없다(0장 0.6). fail()·kit_psql 이 아직 없으므로 직접 낸다.
[ -r ./kit_psql.sh ] || {
  echo "오류: kit 파일 kit_psql.sh 을(를) 읽을 수 없습니다." >&2
  echo "  다음: 파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)." >&2
  exit 1; }
. ./kit_psql.sh

IMAGE="postgres:18"
DB="$KIT_DB"
TEMPLATE="$KIT_TEMPLATE_DB"
CONTAINER="$KIT_CONTAINER"
PORT="$KIT_PORT"
ADMIN="$KIT_ADMIN_DB"

fail() { # $1=원인, $2=다음에 할 일
  echo "오류: $1" >&2
  [ "${2:-}" = "" ] || echo "  다음: $2" >&2
  exit 1
}

# 이 스크립트가 끝에 부르는 kit 스크립트 — 없으면 셸이 「No such file」 한 줄만 내고 끝나 kit 의 안내가 나올
# 자리가 없으므로, 무엇을 하기 전에 먼저 본다.
for _f in reset.sh check_env.sh; do
  [ -f "./$_f" ] && [ -x "./$_f" ] || fail "kit 파일 $_f 을(를) 실행할 수 없습니다 (없거나 실행 권한이 없습니다)" "파일이 지워졌다면 kit을 다시 받으세요 (0장 0.3절). 파일은 있는데 권한이 없으면 chmod +x $_f 뒤 다시 실행하세요"
done

# 답을 적는 파일을 먼저 마련한다 — 아래 구축이 어디선가 막히더라도 문항은 읽을 수 있고,
# 이미 적어 두신 답은 어느 경우에도 그대로 남는다.
entry_answers_prepare() { # entry/templates/qN.sql → entry/qN.sql (없을 때만)
  local created="" kept="" q src dst
  for q in q1 q2 q3 q4; do
    src="entry/templates/$q.sql"; dst="entry/$q.sql"
    if [ -f "$dst" ]; then kept="${kept:+$kept }$dst"; continue; fi
    if [ ! -f "$src" ]; then
      echo "오류: 입장 점검 문항 파일의 원본이 없습니다: $src" >&2
      echo "  다음: 0장 0.3절대로 kit 폴더를 통째로 다시 받은 뒤 ./setup.sh 를 실행하세요." >&2
      exit 1
    fi
    cp "$src" "$dst" 2>/dev/null || {
      echo "오류: 입장 점검 문항 파일을 만들지 못했습니다: $dst" >&2
      echo "  다음: kit 폴더에 파일을 쓸 수 있는 권한이 있는지 확인한 뒤 ./setup.sh 를 다시 실행하세요." >&2
      exit 1; }
    created="${created:+$created }$dst"
  done
  [ -z "$created" ] || echo "입장 점검 답안 파일 생성: $created (문항은 각 파일의 머리 주석에 있습니다)"
  [ -z "$kept" ] || echo "입장 점검 답안 파일 유지: $kept (이미 적어 두신 내용은 그대로 둡니다)"
}

# 같은 world 를 쓰는 다른 실행(./verify.sh·./sessions.sh 등)이 돌고 있으면 원본을 건드리기 전에 멈춘다 — 원본을
# 다시 만들거나 world 를 되돌리면 그 실행이 전제한 상태가 사라진다 (kit_psql.sh 「러너 동시 실행 보호」).
refuse_if_busy() {
  local owner
  owner="$(kit_lock_owner)"
  [ -z "$owner" ] && return 0
  echo "오류: 같은 world($(kit_lock_target))를 쓰는 다른 실행(PID $owner)이 있습니다 — 지금 구축을 이어 가면 그 실행의 결과가 깨집니다." >&2
  echo "  다음: 그 실행이 끝난 뒤 ./setup.sh 를 다시 실행하세요 (다른 터미널이나 다른 폴더에 받아 둔 kit의 ./verify.sh·./entry_check.sh·./sessions.sh·./measure.sh·./workload.sh 입니다)." >&2
  exit 2
}

# world 원본을 만든다 — 이미 지금 kit 파일로 만든 원본이 있으면 건너뛴다.
# 원본을 만드는 방법은 두 경로가 같다 — 원본 데이터베이스를 만드는 CREATE DATABASE 의 로케일 지정까지.
template_build() {
  local stamp now f t0 t1
  # 원본을 만드는 데 쓰는 kit 파일 — 없으면 셸의 입력 리디렉션이 먼저 실패해 kit 의 문구가 나올
  # 자리가 없으므로, 무엇을 지우기 전에 먼저 본다.
  for f in $KIT_WORLD_FILES; do
    [ -r "$f" ] || fail "kit 파일 $f 을(를) 읽을 수 없습니다" "파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)"
  done
  stamp=$(kit_world_stamp)
  if kit_template_exists; then
    now=$(kit_psql -d "$ADMIN" -tAc "SELECT shobj_description(oid, 'pg_database') FROM pg_database WHERE datname = '$TEMPLATE'" 2>/dev/null || true)
    if [ "$now" = "$stamp" ]; then
      echo "world 원본 유지: $TEMPLATE (지금 kit 파일로 만든 원본이 이미 있습니다)"
      return 0
    fi
  fi

  echo "world 원본 만들기: $TEMPLATE — 1분 안팎 걸립니다 (판매 150만 건·회원 30만 명 등을 만들고 뒷정리·통계 수집까지)"
  t0=$(date +%s)
  # 같은 이름의 옛 원본(다른 kit 파일로 만들었거나 만들다 멈춘 것)을 지운다. 원본은 접속을 막아 두었고
  # 누가 붙어 있을 일이 없지만, 만들다 멈춘 원본에는 붙어 있던 세션이 남을 수 있어 FORCE 로 끊는다.
  kit_psql -d "$ADMIN" -q -v ON_ERROR_STOP=1 -c "DROP DATABASE IF EXISTS \"$TEMPLATE\" WITH (FORCE)" >/dev/null 2>&1 \
    || fail "옛 world 원본($TEMPLATE)을 지우지 못했습니다" "잠시 뒤 ./setup.sh 를 다시 실행하세요. 반복되면 $(kit_connect_hint) 로 접속해 DROP DATABASE \"$TEMPLATE\" WITH (FORCE); 를 실행한 뒤 다시 하세요"
  # 정렬 규칙(collation)과 문자 분류를 못 박아 만든다 — 두 경로가 같은 문장으로 만든다. 로케일을 지정하지
  # 않으면 서버의 기본값(대안 경로의 전형값 en_US.UTF-8, 기본 경로의 컨테이너는 libc C.UTF-8)을 물려받아,
  # 한글 ORDER BY 의 차례와 앞부분이 정해진 LIKE('abc%')가 인덱스를 쓸 수 있는지가 경로마다 갈린다.
  # libc 의 'C.UTF-8' 은 macOS 등에 없어 이식성이 없으므로 PostgreSQL 의 builtin 제공자를 쓴다(17부터 있다).
  # LC_COLLATE·LC_CTYPE 'C' 는 libc 쪽 설정도 서버 기본 로케일이 아니라 C 로 못 박는 것이다
  # (kit_psql.sh 「libc 문자 분류」). 로케일을 바꿔 만들려면 TEMPLATE template0 이 필요하다.
  if ! kit_psql -d "$ADMIN" -q -v ON_ERROR_STOP=1 -c "CREATE DATABASE \"$TEMPLATE\" TEMPLATE template0 ENCODING 'UTF8' LOCALE_PROVIDER builtin BUILTIN_LOCALE 'C.UTF-8' LC_COLLATE 'C' LC_CTYPE 'C'" >/dev/null 2>&1; then
    if [ "$KIT_MODE" = native ]; then
      fail "world 원본 데이터베이스 $TEMPLATE 를 만들지 못했습니다 (권한 문제일 수 있습니다)" \
           "데이터베이스를 만들 수 있는 슈퍼유저로 접속하도록 PGUSER 를 바꿔 이 스크립트를 다시 실행하세요 (예: PGUSER=postgres KIT_MODE=native ./setup.sh). 권한 문제가 아니라면 서버가 PostgreSQL 18인지 확인하세요"
    else
      fail "world 원본 데이터베이스 $TEMPLATE 를 만들지 못했습니다 (컨테이너 $CONTAINER)" \
           "docker logs $CONTAINER 로 서버 메시지를 확인하고, 막히면 docker rm -f $CONTAINER 뒤 ./setup.sh 를 다시 실행하세요"
    fi
  fi

  # 원본의 정렬 규칙을 실제 정렬로 확인한다 (메타데이터 문자열이 아니라).
  local sort_now
  sort_now=$(kit_sort_probe "$TEMPLATE" 2>/dev/null || true)
  if [ "$sort_now" != "$KIT_SORT_EXPECTED" ]; then
    echo "        기대한 차례: $KIT_SORT_EXPECTED" >&2
    echo "        실제 차례:   ${sort_now:-(확인 실패)}" >&2
    fail "world 원본 $TEMPLATE 의 정렬 규칙이 코스가 기대하는 것과 다릅니다" "서버가 PostgreSQL 18 인지 확인한 뒤 ./setup.sh 를 다시 실행하세요"
  fi

  # 적재하는 세션도 world 와 같은 설정으로 돌게 원본에 세션 설정을 건다 (복제본에는 따라가지 않는다).
  kit_session_fix "$TEMPLATE" >/dev/null 2>&1 \
    || fail "world 원본 $TEMPLATE 의 세션 설정을 고정하지 못했습니다 (권한 문제일 수 있습니다)" \
            "슈퍼유저로 접속하도록 PGUSER 를 바꿔 이 스크립트를 다시 실행하세요 (예: PGUSER=postgres KIT_MODE=native ./setup.sh)"

  local out step
  for f in $KIT_WORLD_FILES; do
    step="$f 적재"
    if ! out=$(kit_psql -d "$TEMPLATE" -X -q -v ON_ERROR_STOP=1 < "$f" 2>&1); then
      [ -z "$out" ] || printf '%s\n' "$out" | sed 's/^/  /' >&2
      fail "world 원본 만들기 실패 ($step) — 데이터베이스 $TEMPLATE" "./setup.sh 를 다시 실행하세요 — 원본을 처음부터 다시 만듭니다. 반복되면 위 메시지와 함께 디스크 여유 공간(1GB 이상)을 확인하세요"
    fi
  done
  # 관찰 도구 확장. pg_stat_statements 는 서버가 라이브러리를 올려 두어야 조회되지만(아래 확인) 확장 자체는
  # 지금 만들어 둔다 — 원본에 넣어 두면 복제한 world 에 그대로 있다.
  if ! out=$(kit_psql -d "$TEMPLATE" -X -q -v ON_ERROR_STOP=1 2>&1 <<'EOF_EXT'
SET client_min_messages = warning;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pageinspect;
CREATE EXTENSION IF NOT EXISTS pg_buffercache;
CREATE EXTENSION IF NOT EXISTS pgstattuple;
CREATE EXTENSION IF NOT EXISTS pg_visibility;
EOF_EXT
  ); then
    [ -z "$out" ] || printf '%s\n' "$out" | sed 's/^/  /' >&2
    if [ "$KIT_MODE" = native ]; then
      fail "world 원본에 관찰 도구 확장(pg_stat_statements·pageinspect·pg_buffercache·pgstattuple·pg_visibility)을 만들지 못했습니다" \
           "PostgreSQL 18 의 확장 모음(contrib)이 함께 설치되어 있는지 확인한 뒤 ./setup.sh 를 다시 실행하세요 — Homebrew·Postgres.app 은 기본으로 들어 있고, Linux·WSL2 의 PGDG 패키지 postgresql-18 에도 들어 있습니다"
    else
      fail "world 원본에 관찰 도구 확장을 만들지 못했습니다 (컨테이너 $CONTAINER)" "docker rm -f $CONTAINER 뒤 ./setup.sh 를 다시 실행하세요"
    fi
  fi
  # 뒷정리·얼림·통계 수집. 되돌린 직후의 world 가 «정착 상태»여야 한다 — 적재 직후에는 가시성 맵이
  # 비어 있다가 1분쯤 뒤 자동 뒷정리(autovacuum)가 채우고, 처음 읽는 질의가 힌트 비트를 쓰느라 페이지를
  # 더럽힌다. 그래서 실행 계획과 버퍼 수가 「되돌린 직후」와 「조금 지난 뒤」에 갈린다. 원본에서 여기까지
  # 끝내 두면 복제가 그 상태를 그대로 옮긴다.
  if ! out=$(kit_psql -d "$TEMPLATE" -X -q -v ON_ERROR_STOP=1 -c "VACUUM (FREEZE, ANALYZE);" 2>&1); then
    [ -z "$out" ] || printf '%s\n' "$out" | sed 's/^/  /' >&2
    fail "world 원본 만들기 실패 (뒷정리·통계 수집) — 데이터베이스 $TEMPLATE" "./setup.sh 를 다시 실행하세요"
  fi
  # 접속을 막고(복제는 원본에 붙은 세션이 없어야 된다) 어떤 kit 파일로 만들었는지 적는다 — 이 설명이
  # 마지막이어야 만들다 멈춘 원본을 다음 실행이 알아본다.
  if ! out=$(kit_psql -d "$ADMIN" -X -q -v ON_ERROR_STOP=1 \
               -c "ALTER DATABASE \"$TEMPLATE\" ALLOW_CONNECTIONS false" \
               -c "COMMENT ON DATABASE \"$TEMPLATE\" IS '$stamp'" 2>&1); then
    [ -z "$out" ] || printf '%s\n' "$out" | sed 's/^/  /' >&2
    fail "world 원본 마무리에 실패했습니다 — 데이터베이스 $TEMPLATE" "./setup.sh 를 다시 실행하세요"
  fi
  t1=$(date +%s)
  echo "world 원본 완료: $TEMPLATE ($((t1 - t0))초)"
}

entry_answers_prepare

if [ "$KIT_MODE" = native ]; then
  echo "대안 경로(KIT_MODE=native): 컨테이너를 만들지 않고, 설치하신 PostgreSQL에 접속합니다."
  echo "  접속 정보는 psql의 환경 변수를 그대로 씁니다 — PGHOST·PGPORT·PGUSER·PGPASSWORD."

  if ! command -v "$KIT_PSQL" >/dev/null 2>&1; then
    echo "오류: psql 명령을 찾을 수 없습니다 ($KIT_PSQL)." >&2
    echo "  다음: 0장 0.7절(대안 경로)대로 PostgreSQL 18을 설치하세요" >&2
    echo "        (macOS: Homebrew 또는 Postgres.app / Windows: WSL2 안에서 Linux와 같이 / Linux: 배포판 패키지 또는 PGDG)." >&2
    echo "        설치했는데 잡히지 않으면 KIT_PSQL=/설치경로/psql 로 지정하세요." >&2
    exit 1
  fi

  # 서버 접속 확인 (world 는 아직 없을 수 있으므로 관리용 데이터베이스로 붙어 본다)
  if ! kit_psql -d "$ADMIN" -tAc "SELECT 1" >/dev/null 2>&1; then
    echo "오류: PostgreSQL 서버에 접속하지 못했습니다 (데이터베이스 $ADMIN)." >&2
    echo "  다음: 서버가 실행 중인지 확인하고(예: macOS Homebrew는 brew services start postgresql@18, Linux·WSL2는 sudo systemctl start postgresql — 이때 PGHOST=localhost도 지정)," >&2
    echo "        접속 정보를 PGHOST·PGPORT·PGUSER·PGPASSWORD로 맞춘 뒤 다시 실행하세요." >&2
    echo "        관리용 데이터베이스 이름이 postgres가 아니면 KIT_ADMIN_DB로 지정하세요." >&2
    exit 1
  fi

  ver=$(kit_psql -d "$ADMIN" -tAc "SHOW server_version;")
  case "$ver" in
    18.*) echo "PostgreSQL $ver 확인 (이 코스의 기준: 메이저 18)" ;;
    *) fail "서버 버전 $ver — 이 코스가 쓰는 메이저 18이 아닙니다." \
            "PostgreSQL 18을 설치하고 PGPORT 등으로 접속을 그쪽으로 돌린 뒤 다시 실행하세요." ;;
  esac

  # 슈퍼유저인가 — world 원본에 관찰 도구 확장을 만들고(pageinspect 등은 슈퍼유저만 만들 수 있다)
  # 메시지 언어·I/O 시간 측정 같은 설정을 데이터베이스에 거는 데 필요하다.
  if [ "$(kit_psql -d "$ADMIN" -tAc "SELECT rolsuper FROM pg_roles WHERE rolname = current_user")" != "t" ]; then
    fail "지금 접속한 역할($(kit_psql -d "$ADMIN" -tAc "SELECT current_user"))이 슈퍼유저가 아닙니다 — 이 코스의 world 는 관찰 도구 확장과 데이터베이스 설정을 슈퍼유저 권한으로 만듭니다." \
         "슈퍼유저로 접속하도록 PGUSER 를 바꿔 이 스크립트를 다시 실행하세요 (예: PGUSER=postgres KIT_MODE=native ./setup.sh)"
  fi

  # pg_stat_statements — 서버가 시작할 때 올려 두어야 한다. kit 은 여러분 서버의 설정 파일을 고치지 않는다.
  if ! kit_preload_ok "$ADMIN"; then
    cur=$(kit_psql -d "$ADMIN" -tAc "SHOW shared_preload_libraries;" 2>/dev/null || true)
    echo "오류: 서버에 pg_stat_statements 가 올라와 있지 않습니다 (지금 shared_preload_libraries = '${cur}')." >&2
    echo "        이 코스는 1장부터 이 관찰 도구로 질의를 측정합니다. 서버가 시작할 때 읽는 설정이라 서버를 다시 시작해야 합니다." >&2
    echo "  다음: psql -d $ADMIN -c \"ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements'\" 를 실행하고(이미 다른 값이 있으면 쉼표로 이어 적으세요)," >&2
    echo "        서버를 다시 시작한 뒤(macOS Homebrew는 brew services restart postgresql@18, Linux·WSL2는 sudo systemctl restart postgresql) KIT_MODE=native ./setup.sh 를 다시 실행하세요." >&2
    exit 1
  fi

  refuse_if_busy
  template_build

  ./reset.sh
  ./check_env.sh
  kit_state_save native

  cat <<EOF

구축 완료 (대안 경로). psql 접속:
  $(kit_connect_hint)
  (kit 폴더에서는 ./psql.sh 로도 열 수 있습니다)

이후 ./reset.sh · ./check_env.sh · ./entry_check.sh · ./verify.sh · ./sessions.sh · ./measure.sh ·
./workload.sh · ./psql.sh 는 KIT_MODE 없이 그대로 실행하시면 됩니다 — 구축 경로를 $KIT_STATE_FILE 에
적어 두었으므로 챕터 본문의 맨 ./reset.sh 안내가 이 경로에서도 그대로 통합니다.
다음 단계: ./entry_check.sh 로 입장 점검(4문)을 통과하세요 (README 「입장 점검」).
EOF
  exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "오류: docker 명령을 찾을 수 없습니다. 런타임을 먼저 설치하세요 (0장 0.1절)." >&2
  echo "  다음: 런타임을 쓸 수 없는 환경이면 0장 0.7절의 대안 경로(직접 설치) 뒤" >&2
  echo "        KIT_MODE=native ./setup.sh 로 실행하세요." >&2
  exit 1
fi

# docker 명령이 있어도 런타임 프로그램이 꺼져 있으면 아래 docker run 이 말없이
# 실패한다. 컨테이너를 만지기 전에 데몬 접속을 확인해 원인을 특정한다.
if ! docker info >/dev/null 2>&1; then
  echo "오류: 런타임이 실행 중이 아닙니다 — docker 명령은 있지만 런타임 프로그램이 응답하지 않습니다 (0장 0.1절)." >&2
  echo "  다음: Windows는 Docker Desktop을 실행하고 Settings > Resources > WSL Integration에서 Ubuntu가 켜져 있는지 확인하세요 / macOS는 OrbStack을 실행하세요 / Linux는 sudo systemctl start docker 로 Docker 서비스를 시작하세요 (0장 0.1절)." >&2
  echo "        그 뒤 ./setup.sh 를 다시 실행하세요." >&2
  exit 1
fi

if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
    echo "기존 컨테이너 시작: $CONTAINER"
    docker start "$CONTAINER" >/dev/null \
      || fail "컨테이너 $CONTAINER 를 시작하지 못했습니다 (위 docker 메시지 참고 — 포트 $PORT 를 다른 프로그램이 쓰고 있을 수 있습니다)" \
              "포트를 쓰는 프로그램을 멈추거나, docker rm -f $CONTAINER 뒤 다른 포트로 KIT_PORT=<포트> ./setup.sh 를 실행하세요 (그 뒤의 명령에도 같은 KIT_PORT 를 붙입니다)"
  else
    echo "컨테이너 실행 중: $CONTAINER"
  fi
else
  echo "컨테이너 생성: $CONTAINER (이미지 $IMAGE, 호스트 포트 $PORT)"
  # 서버 설정 두 가지를 컨테이너를 만들 때 정한다 — 둘 다 서버가 시작할 때만 읽는 값이다.
  #   shared_preload_libraries=pg_stat_statements  1장부터 쓰는 질의 측정 도구
  #   shared_buffers=128MB                         공유 버퍼 크기 (PostgreSQL 기본값을 명시로 못 박는다)
  # --shm-size 는 컨테이너의 공유 메모리(/dev/shm) 크기다. Docker 의 기본값 64MB 는 큰 테이블의 병렬
  # 해시 조인이 쓰는 공유 메모리에 모자랄 수 있어 넉넉히 준다.
  docker run -d --name "$CONTAINER" \
    --shm-size=256m \
    -e POSTGRES_PASSWORD=learning \
    -e LANG=C.UTF-8 \
    -p "$PORT:5432" \
    "$IMAGE" \
    -c shared_preload_libraries=pg_stat_statements \
    -c shared_buffers=128MB >/dev/null \
    || fail "컨테이너 $CONTAINER 를 만들지 못했습니다 (위 docker 메시지 참고 — 포트 $PORT 를 다른 프로그램이 쓰고 있거나, 이미지 $IMAGE 를 내려받지 못했을 수 있습니다)" \
            "docker rm -f $CONTAINER 로 반쯤 만들어진 컨테이너를 지운 뒤, 포트가 문제면 다른 포트로 KIT_PORT=<포트> ./setup.sh 를, 내려받기가 문제면 인터넷 연결을 확인하고 ./setup.sh 를 다시 실행하세요 (다른 포트를 썼으면 그 뒤의 명령에도 같은 KIT_PORT 를 붙입니다)"
fi

# 공식 이미지는 첫 기동 때 초기화용 임시 서버를 한 번 띄웠다 내리고 본 서버를 띄운다.
# 그 임시 서버는 «소켓만» 듣는다 — 업스트림 entrypoint의 docker_temp_server_start 가
# -c listen_addresses='' 로 띄우기 때문이다. 그래서 pg_isready 를 소켓으로 부르면 임시 서버도
# 「준비 완료」로 읽힌다. TCP 로 물어 본 서버만 통과시키고, 실제 질의까지 한 번 더 확인한다.
# 시한은 60회 시도(한 번에 1초 쉼 — 벽시계로는 60초보다 조금 길다)다.
printf '%s' "서버 준비 대기"
for _ in $(seq 1 60); do
  if docker exec "$CONTAINER" pg_isready -h 127.0.0.1 -U postgres -q 2>/dev/null \
     && kit_psql -d "$ADMIN" -tAc "SELECT 1" >/dev/null 2>&1; then
    ready=1; break
  fi
  printf '.'; sleep 1
done
echo
[ "${ready:-0}" = 1 ] || {
  echo "오류: 60초 내에 서버가 준비되지 않았습니다 (컨테이너 $CONTAINER)." >&2
  echo "  다음: 첫 실행이거나 컴퓨터가 느리면 잠시 뒤 ./setup.sh 를 한 번 더 실행하세요. 반복되면 docker logs $CONTAINER 로 서버가 남긴 메시지를 확인하고, 그래도 막히면 docker rm -f $CONTAINER 뒤 ./setup.sh 를 다시 실행하세요." >&2
  exit 1; }

# 메이저 버전 확인 (이 코스의 기준: PostgreSQL 18)
ver=$(kit_psql -d "$ADMIN" -tAc "SHOW server_version;")
case "$ver" in
  18.*) echo "PostgreSQL $ver 확인 (이 코스의 기준: 메이저 18)" ;;
  *) fail "서버 버전 $ver — 이 코스가 쓰는 메이저 18이 아닙니다." \
          "docker rm -f $CONTAINER 로 컨테이너를 지운 뒤 ./setup.sh 를 실행하면 postgres:18 이미지로 다시 만듭니다." ;;
esac

# 컨테이너가 이 kit 이 정한 서버 설정으로 떠 있는가 (다른 방법으로 만든 같은 이름의 컨테이너일 수 있다).
kit_preload_ok "$ADMIN" \
  || fail "컨테이너 $CONTAINER 의 서버에 pg_stat_statements 가 올라와 있지 않습니다 — 이 kit 이 만든 컨테이너가 아닙니다." \
          "docker rm -f $CONTAINER 로 컨테이너를 지운 뒤 ./setup.sh 를 실행하면 이 코스의 설정으로 다시 만듭니다."

refuse_if_busy
template_build

./reset.sh
./check_env.sh
kit_state_save docker

cat <<EOF

구축 완료 (기본 경로). psql 접속:
  $(kit_connect_hint)
  (kit 폴더에서는 ./psql.sh 로도 열 수 있습니다)
호스트 psql이 있다면 (선택):
  psql "host=localhost port=$PORT dbname=$DB user=postgres password=learning"

다음 단계: ./entry_check.sh 로 입장 점검(4문)을 통과하세요 (README 「입장 점검」).
EOF
