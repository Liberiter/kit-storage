#!/usr/bin/env bash
# 학습 환경 구축: postgres:18 컨테이너 기동 + world(책숲) 적재 + 검증.
# 전제: Docker 호환 런타임 (0장 0.1절 — Windows: Docker Desktop,
#       macOS: OrbStack, Linux: Docker Engine). 그 외 수작업 불필요.
#
# 대안 경로(0장 0.7절 — 네이티브 설치)는 KIT_MODE=native ./setup.sh.
# 이 경로에서는 컨테이너를 만들 것이 없으므로, 대신 설치하신 서버가 코스에 쓸 수 있는
# 상태인지 점검하고, world를 담을 데이터베이스를 기본 경로와 **같은 정렬 규칙**으로
# 만든 뒤 world를 적재한다 (아래 CREATE DATABASE 주석).
#
# 두 경로 모두 데이터베이스의 **세션 시간대(UTC)·메시지 언어(C)·날짜 표기('ISO, MDY')·
# 로케일(lc_monetary·lc_numeric·lc_time = C)** 를 ALTER DATABASE 로 못 박는다
# (kit_psql.sh 「세션 시간대·메시지 언어·날짜 표기·로케일」). 직접 설치한 서버는 그
# 컴퓨터의 로케일을 기본값으로 잡아, 그대로 두면 오류 메시지가 한국어로 나오고
# to_char 의 통화·요일 표기가 본문과 달라진다. 멱등이므로 기존 데이터베이스에도 다시
# 실행하면 설정이 다시 적용된다. 대안 경로의 데이터베이스는 libc 문자 분류(LC_CTYPE)도
# C 로 만든다 — 다만 이것은 만들 때만 정할 수 있고, 이 코스의 출력에서 이 축에 걸리는
# 것은 1장 1.2 의 \l 이 내는 Ctype 열 한 자리뿐이라(kit_psql.sh 「libc 문자 분류」 —
# 서버 자신의 사실을 비추는 자리다), 다른 값으로 이미 만들어져 있는 데이터베이스는
# 막지 않고 알림만 낸다.
#
# 구축에 성공하면 **어느 경로로 구축했는지를 상태 파일에 적는다**
# (kit_state_save — 정의와 이유는 kit_psql.sh 「구축 경로 기억」). 그래야 대안
# 경로 학습자가 KIT_MODE를 한 번만 지정하고, 이후 챕터 본문(11·12·13장)이 맨
# 명령으로 40곳에 적은 ./reset.sh 를 그대로 쓸 수 있다. 환경 변수 KIT_MODE는
# 언제나 상태 파일을 이기므로 KIT_MODE=native ./setup.sh 로 경로를 바꿔
# 구축하면 상태 파일도 그때 갱신된다.
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
CONTAINER="$KIT_CONTAINER"
PORT="$KIT_PORT"

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

  # 서버 접속 확인 (데이터베이스는 아직 없을 수 있으므로 관리용 postgres DB로 붙어 본다)
  admin_db="${KIT_ADMIN_DB:-postgres}"
  if ! kit_psql -d "$admin_db" -tAc "SELECT 1" >/dev/null 2>&1; then
    echo "오류: PostgreSQL 서버에 접속하지 못했습니다 (데이터베이스 $admin_db)." >&2
    echo "  다음: 서버가 실행 중인지 확인하고(예: macOS Homebrew는 brew services start postgresql@18, Linux·WSL2는 sudo systemctl start postgresql — 이때 PGHOST=localhost도 지정)," >&2
    echo "        접속 정보를 PGHOST·PGPORT·PGUSER·PGPASSWORD로 맞춘 뒤 다시 실행하세요." >&2
    echo "        관리용 데이터베이스 이름이 postgres가 아니면 KIT_ADMIN_DB로 지정하세요." >&2
    exit 1
  fi

  ver=$(kit_psql -d "$admin_db" -tAc "SHOW server_version;")
  case "$ver" in
    18.*) echo "PostgreSQL $ver 확인 (이 코스의 기준: 메이저 18)" ;;
    *)
      echo "오류: 서버 버전 $ver — 이 코스가 쓰는 메이저 18이 아닙니다." >&2
      echo "  다음: PostgreSQL 18을 설치하고 PGPORT 등으로 접속을 그쪽으로 돌린 뒤 다시 실행하세요." >&2
      exit 1 ;;
  esac

  # 정렬 규칙(collation)을 못 박아 만든다 — kit_psql.sh의 KIT_SORT_* 주석 참고.
  # 기본 경로는 컨테이너 initdb를 LANG=C.UTF-8로 고정해 이 성질을 얻는데, 대안
  # 경로에서 로케일을 지정하지 않으면 학습자 서버의 기본값(전형값 en_US.UTF-8)을
  # 상속해 한글 ORDER BY의 차례가 본문의 표와 달라진다.
  # libc의 'C.UTF-8'은 macOS 등에 없어 이식성이 없으므로 PostgreSQL 18의
  # builtin 제공자를 쓴다. 로케일을 바꿔 만들 때는 TEMPLATE template0이
  # 필요하다 — template1은 서버 기본 로케일이라 제공자가 어긋난다
  # ("new locale provider (builtin) does not match ... use template0").
  # LC_CTYPE·LC_COLLATE 'C' 는 서버 기본 로케일을 물려받아 C 계열 밖으로 나가는 것을
  # 막는다. 컨테이너와 «값»이 같아지지는 않지만(컨테이너는 C.UTF-8, 이쪽은 C)
  # **거동은 같다** — 대소문자·문자 클래스는 제공자와 그 로케일이 맡고 여기서는
  # BUILTIN_LOCALE 'C.UTF-8' 이 그 역할을 한다 (kit_psql.sh 「libc 문자 분류」).
  if [ "$(kit_psql -d "$admin_db" -tAc "SELECT 1 FROM pg_database WHERE datname='$DB'")" != "1" ]; then
    if kit_psql -d "$admin_db" -q -c "CREATE DATABASE \"$DB\" TEMPLATE template0 ENCODING 'UTF8' LOCALE_PROVIDER builtin BUILTIN_LOCALE 'C.UTF-8' LC_COLLATE 'C' LC_CTYPE 'C'" >/dev/null 2>&1; then
      echo "데이터베이스 생성: $DB (정렬 규칙 C.UTF-8 고정 — builtin 제공자, libc 문자 분류 C)"
    else
      echo "오류: 데이터베이스 $DB 를 만들지 못했습니다 (권한 문제일 수 있습니다)." >&2
      echo "  다음: 데이터베이스를 만들 수 있는 역할로 아래 명령을 실행한 뒤 이 스크립트를 다시 실행하세요." >&2
      echo "        createdb --template=template0 --encoding=UTF8 --locale-provider=builtin --builtin-locale=C.UTF-8 --lc-collate=C --lc-ctype=C $DB" >&2
      echo "        (권한 문제가 아니라면 서버가 PostgreSQL 18인지 확인하세요 — builtin 로케일 제공자는 17부터 있습니다.)" >&2
      exit 1
    fi
  fi

  # 이미 있던 $DB가 다른 로케일로 만들어졌을 수 있다 (이 스크립트가 로케일을
  # 고정하기 전에 ./setup.sh를 돌린 학습자). 메타데이터가 아니라 실제 정렬로
  # 확인한다 — 제공자가 다르면 datcollate 문자열은 어긋난다.
  sort_now=$(kit_sort_probe "$DB" 2>/dev/null || true)
  if [ "$sort_now" != "$KIT_SORT_EXPECTED" ]; then
    echo "오류: 데이터베이스 $DB 의 정렬 규칙이 코스가 기대하는 것과 다릅니다." >&2
    echo "        기대한 차례: $KIT_SORT_EXPECTED" >&2
    echo "        실제 차례:   ${sort_now:-(확인 실패)}" >&2
    echo "        이대로 두면 9·11·12·13장에서 교재 본문과 차례가 다른 표를 보게 됩니다." >&2
    echo "  다음: 이 데이터베이스는 다른 로케일로 만들어졌습니다. dropdb $DB 로 지운 뒤" >&2
    echo "        ./setup.sh 를 다시 실행하세요 — 정렬 규칙을 고정해 새로 만들고 world를" >&2
    echo "        seed.sql에서 다시 적재하므로 잃는 것이 없습니다." >&2
    exit 1
  fi

  # 이미 있던 $DB의 libc 문자 분류(LC_CTYPE)가 C 계열이 아니어도 **막지 않는다.**
  # 이 축이 영향을 주는 자리는 넓지만(확인된 목록은 kit_psql.sh 「libc 문자 분류」 —
  # 전부라고 단정하지 않는다), 이 코스의 출력에서 실제로 갈리는 것은 1장 1.2 의
  # ch01-04-list-databases 한 건뿐이다 — \l 이 내는 Ctype 열이 datctype 을 그대로
  # 비추고, 그 줄은 서버 자신의 사실을 비추는 자리라 kit 이 이미 경로 축으로 세고 있다. 알림은 아래에서 부르는 ./check_env.sh 가 한 번만 낸다 — 여기서도 내면
  # 구축 화면에 같은 말이 두 번 찍힌다.

  # 세션 시간대·메시지 언어·날짜 표기·로케일(통화·숫자·날짜 이름)을 데이터베이스 설정으로
  # 고정한다 (기본 경로와 같은 값 — kit_psql.sh 「세션 시간대·메시지 언어·날짜 표기·로케일」).
  if kit_session_fix "$DB" >/dev/null 2>&1; then
    echo "세션 설정 고정: timezone=UTC, lc_messages=C, DateStyle='ISO, MDY', lc_monetary/lc_numeric/lc_time=C (데이터베이스 $DB 의 기본값으로 — 여러분의 psql 세션에도 적용됩니다)"
  else
    echo "오류: 데이터베이스 $DB 의 세션 설정(timezone·lc_messages·DateStyle·lc_monetary·lc_numeric·lc_time)을 고정하지 못했습니다 (권한 문제일 수 있습니다)." >&2
    echo "  다음: 슈퍼유저(예: postgres)로 아래 명령들을 실행한 뒤 이 스크립트를 다시 실행하세요." >&2
    echo "        ALTER DATABASE \"$DB\" SET timezone TO 'UTC';" >&2
    echo "        ALTER DATABASE \"$DB\" SET lc_messages TO 'C';" >&2
    echo "        ALTER DATABASE \"$DB\" SET DateStyle TO 'ISO, MDY';" >&2
    echo "        ALTER DATABASE \"$DB\" SET lc_monetary TO 'C';  ALTER DATABASE \"$DB\" SET lc_numeric TO 'C';  ALTER DATABASE \"$DB\" SET lc_time TO 'C';" >&2
    exit 1
  fi

  ./reset.sh
  ./check_env.sh
  kit_state_save native

  cat <<EOF

구축 완료 (대안 경로). psql 접속:
  $(kit_connect_hint)

이후 ./reset.sh · ./check_env.sh · ./verify.sh 는 KIT_MODE 없이 그대로 실행하시면
됩니다 — 구축 경로를 $KIT_STATE_FILE 에 적어 두었으므로 챕터 본문의 맨
./reset.sh 안내가 이 경로에서도 그대로 통합니다.
EOF
  exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "오류: docker 명령을 찾을 수 없습니다. 런타임을 먼저 설치하세요 (0장 0.1절)." >&2
  echo "  다음: 런타임을 쓸 수 없는 환경이면 0장 0.7절의 대안 경로(네이티브 설치) 뒤" >&2
  echo "        KIT_MODE=native ./setup.sh 로 실행하세요." >&2
  exit 1
fi

# docker 명령이 있어도 런타임 프로그램이 꺼져 있으면 아래 docker run 이 말없이
# 실패한다 (Windows에서는 Docker Desktop이 꺼졌거나 WSL Integration이 꺼진 채로
# 남은 docker 가 안내문만 내고 실패한다). 컨테이너를 만지기 전에 데몬 접속을
# 확인해 원인을 특정한다.
if ! docker info >/dev/null 2>&1; then
  echo "오류: 런타임이 실행 중이 아닙니다 — docker 명령은 있지만 런타임 프로그램이 응답하지 않습니다 (0장 0.1절)." >&2
  echo "  다음: Windows는 Docker Desktop을 실행하고 Settings > Resources > WSL Integration에서 Ubuntu가 켜져 있는지 확인하세요 / macOS는 OrbStack을 실행하세요 / Linux는 sudo systemctl start docker 로 Docker 서비스를 시작하세요 (0장 0.1절)." >&2
  echo "        그 뒤 ./setup.sh 를 다시 실행하세요." >&2
  exit 1
fi

if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
    echo "기존 컨테이너 시작: $CONTAINER"
    docker start "$CONTAINER" >/dev/null
  else
    echo "컨테이너 실행 중: $CONTAINER"
  fi
else
  echo "컨테이너 생성: $CONTAINER (이미지 $IMAGE, 호스트 포트 $PORT)"
  docker run -d --name "$CONTAINER" \
    -e POSTGRES_PASSWORD=learning \
    -e LANG=C.UTF-8 \
    -p "$PORT:5432" \
    "$IMAGE" >/dev/null
fi

# 공식 이미지는 첫 기동 때 초기화용 임시 서버를 한 번 띄웠다 내리고 본 서버를 띄운다.
# 그 임시 서버는 «소켓만» 듣는다 — 업스트림 entrypoint의 docker_temp_server_start 가
# -c listen_addresses='' 로 띄우기 때문이다("does not listen on external TCP/IP").
# 그래서 pg_isready 를 소켓으로 부르면 임시 서버도 「준비 완료」로 읽히고, 그 서버가
# 내려가는 틈(실측 106ms)에 다음 질의가 붙으면 kit 문구 없이 psql 원문 오류로 죽는다.
# TCP 로 물어 본 서버만 통과시킨다. 실제 질의까지 한 번 더 확인한다.
echo -n "서버 준비 대기"
for _ in $(seq 1 60); do
  if docker exec "$CONTAINER" pg_isready -h 127.0.0.1 -U postgres -q 2>/dev/null \
     && kit_psql -d postgres -tAc "SELECT 1" >/dev/null 2>&1; then
    ready=1; break
  fi
  echo -n "."; sleep 1
done
echo
[ "${ready:-0}" = 1 ] || {
  echo "오류: 60초 내에 서버가 준비되지 않았습니다 (컨테이너 $CONTAINER)." >&2
  echo "  다음: 첫 실행이거나 컴퓨터가 느리면 잠시 뒤 ./setup.sh 를 한 번 더 실행하세요. 반복되면 docker logs $CONTAINER 로 서버가 남긴 메시지를 확인하고, 그래도 막히면 docker rm -f $CONTAINER 뒤 ./setup.sh 를 다시 실행하세요." >&2
  exit 1; }

# 메이저 버전 확인 (이 코스의 기준: PostgreSQL 18)
ver=$(kit_psql -tAc "SHOW server_version;")
case "$ver" in
  18.*) echo "PostgreSQL $ver 확인 (이 코스의 기준: 메이저 18)" ;;
  *)
    echo "오류: 서버 버전 $ver — 이 코스가 쓰는 메이저 18이 아닙니다." >&2
    echo "  다음: 컨테이너 $CONTAINER 가 다른 판으로 먼저 만들어져 있습니다. docker rm -f $CONTAINER 로 지운 뒤 ./setup.sh 를 다시 실행하세요 — $IMAGE 이미지로 새로 만들고 world를 다시 적재하므로 잃는 것이 없습니다." >&2
    exit 1 ;;
esac

# 데이터베이스 생성 (없으면)
if [ "$(kit_psql -tAc "SELECT 1 FROM pg_database WHERE datname='$DB'")" != "1" ]; then
  docker exec "$CONTAINER" createdb -U postgres "$DB"
  echo "데이터베이스 생성: $DB"
fi

# 세션 시간대·메시지 언어·날짜 표기·로케일(통화·숫자·날짜 이름)을 데이터베이스 설정으로
# 고정한다. 컨테이너는 원래 Etc/UTC·C.UTF-8·'ISO, MDY' 이지만, 대안 경로와 **같은 값**을
# 같은 방법으로 못 박아 두 경로의 world 가 같음을 설정 하나로 보장한다
# (kit_psql.sh 「세션 시간대·메시지 언어·날짜 표기·로케일」).
if kit_session_fix "$DB" >/dev/null 2>&1; then
  echo "세션 설정 고정: timezone=UTC, lc_messages=C, DateStyle='ISO, MDY', lc_monetary/lc_numeric/lc_time=C (데이터베이스 $DB 의 기본값으로)"
else
  echo "오류: 데이터베이스 $DB 의 세션 설정(timezone·lc_messages·DateStyle·lc_monetary·lc_numeric·lc_time)을 고정하지 못했습니다." >&2
  echo "  다음: docker logs $CONTAINER 로 서버 로그를 확인하세요. 막히면 docker rm -f $CONTAINER 뒤 ./setup.sh 를 다시 실행하세요." >&2
  exit 1
fi

./reset.sh
./check_env.sh
kit_state_save docker

cat <<EOF

구축 완료 (기본 경로). psql 접속:
  $(kit_connect_hint)
호스트 psql이 있다면 (선택):
  psql "host=localhost port=$PORT dbname=$DB user=postgres password=learning"
EOF
