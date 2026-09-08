#!/usr/bin/env bash
# 학습 환경 구축: postgres:18 컨테이너 기동 + world(책숲) 적재 + 검증.
# 전제: Docker 호환 런타임 (0장 0.1절 — Windows: Docker Desktop,
#       macOS: OrbStack, Linux: Docker Engine). 그 외 수작업 불필요.
#
# 대안 경로(0장 0.7절 — 네이티브 설치)는 KIT_MODE=native ./setup.sh.
# 이 경로에서는 컨테이너를 만들 것이 없으므로, 대신 학습자가 설치한 서버가
# 코스에 쓸 수 있는 상태인지 점검하고, world를 담을 데이터베이스를 기본 경로와
# **같은 정렬 규칙**으로 만든 뒤 world를 적재한다 (아래 CREATE DATABASE 주석).
#
# 구축에 성공하면 **어느 경로로 구축했는지를 상태 파일에 적는다**
# (kit_state_save — 정의와 이유는 kit_psql.sh 「구축 경로 기억」). 그래야 대안
# 경로 학습자가 KIT_MODE를 한 번만 지정하고, 이후 챕터 본문(11·12·13장)이 맨
# 명령으로 40곳에 적은 ./reset.sh 를 그대로 쓸 수 있다. 환경 변수 KIT_MODE는
# 언제나 상태 파일을 이기므로 KIT_MODE=native ./setup.sh 로 경로를 바꿔
# 구축하면 상태 파일도 그때 갱신된다.
set -euo pipefail
cd "$(dirname "$0")"
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
  if [ "$(kit_psql -d "$admin_db" -tAc "SELECT 1 FROM pg_database WHERE datname='$DB'")" != "1" ]; then
    if kit_psql -d "$admin_db" -q -c "CREATE DATABASE \"$DB\" TEMPLATE template0 ENCODING 'UTF8' LOCALE_PROVIDER builtin BUILTIN_LOCALE 'C.UTF-8'" >/dev/null 2>&1; then
      echo "데이터베이스 생성: $DB (정렬 규칙 C.UTF-8 고정 — builtin 제공자)"
    else
      echo "오류: 데이터베이스 $DB 를 만들지 못했습니다 (권한 문제일 수 있습니다)." >&2
      echo "  다음: 데이터베이스를 만들 수 있는 역할로 아래 명령을 실행한 뒤 이 스크립트를 다시 실행하세요." >&2
      echo "        createdb --template=template0 --encoding=UTF8 --locale-provider=builtin --builtin-locale=C.UTF-8 $DB" >&2
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

echo -n "서버 준비 대기"
for _ in $(seq 1 60); do
  if docker exec "$CONTAINER" pg_isready -U postgres -q 2>/dev/null; then
    ready=1; break
  fi
  echo -n "."; sleep 1
done
echo
[ "${ready:-0}" = 1 ] || { echo "오류: 60초 내에 서버가 준비되지 않았습니다." >&2; exit 1; }

# 메이저 버전 확인 (이 코스의 기준: PostgreSQL 18)
ver=$(kit_psql -tAc "SHOW server_version;")
case "$ver" in
  18.*) echo "PostgreSQL $ver 확인 (이 코스의 기준: 메이저 18)" ;;
  *) echo "오류: 서버 버전 $ver — 이 코스가 쓰는 메이저 18이 아닙니다." >&2; exit 1 ;;
esac

# 데이터베이스 생성 (없으면)
if [ "$(kit_psql -tAc "SELECT 1 FROM pg_database WHERE datname='$DB'")" != "1" ]; then
  docker exec "$CONTAINER" createdb -U postgres "$DB"
  echo "데이터베이스 생성: $DB"
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
