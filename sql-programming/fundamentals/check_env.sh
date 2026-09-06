#!/usr/bin/env bash
# 환경 검증 = 코스 entry check(입장 점검)의 판정 기준 (0장 0.5절).
# 접속 → 버전 → world 속성(정렬 규칙 + world_check.sql) 순으로 확인한다.
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
. ./kit_psql.sh

DB="$KIT_DB"

fail() { # $1=원인, $2=다음에 할 일
  echo "entry check 실패: $1" >&2
  [ "${2:-}" = "" ] || echo "  다음: $2" >&2
  exit 1
}

if [ "$KIT_MODE" = native ]; then
  command -v "$KIT_PSQL" >/dev/null 2>&1 \
    || fail "psql 명령 없음 ($KIT_PSQL)" \
            "0장 0.7절(대안 경로)대로 PostgreSQL 18을 설치하고 psql이 PATH에 있는지 확인하세요 (설치했는데 안 잡히면 KIT_PSQL=/설치경로/psql 로 지정)"
else
  command -v docker >/dev/null 2>&1 \
    || fail "docker 명령 없음" \
            "0장 0.1절대로 런타임을 설치하세요 (Windows: Docker Desktop / macOS: OrbStack / Linux: Docker Engine). 런타임을 못 쓰는 환경이면 0장 0.7절의 대안 경로(네이티브 설치) 뒤 KIT_MODE=native ./check_env.sh 로 실행하세요"
  docker ps --format '{{.Names}}' | grep -qx "$KIT_CONTAINER" \
    || fail "컨테이너($KIT_CONTAINER) 미실행" \
            "./setup.sh 를 먼저 실행하세요"
fi

if ! kit_psql -d "$DB" -tAc "SELECT 1" >/dev/null 2>&1; then
  if [ "$KIT_MODE" = native ]; then
    fail "psql 접속 불가 (데이터베이스 $DB)" \
         "PostgreSQL 서버가 떠 있는지(Linux·WSL2는 sudo systemctl start postgresql), 접속 정보(PGHOST·PGPORT·PGUSER·PGPASSWORD — Linux·WSL2는 PGHOST=localhost까지)와 $DB 데이터베이스가 맞는지 확인한 뒤 ./setup.sh 를 실행하세요 — setup.sh가 대안 경로에서 무엇을 점검하는지 안내합니다"
  else
    fail "psql 접속 불가 (컨테이너 $KIT_CONTAINER, 데이터베이스 $DB)" \
         "docker logs $KIT_CONTAINER 로 서버 상태를 본 뒤 ./setup.sh 를 다시 실행하세요"
  fi
fi

ver=$(kit_psql -d "$DB" -tAc "SHOW server_version;")
case "$ver" in
  18.*) ;;
  *)
    if [ "$KIT_MODE" = native ]; then
      fail "서버 버전 $ver (기대: 18.x)" \
           "이 코스가 쓰는 메이저는 18입니다. 대안 경로 안내대로 PostgreSQL 18을 설치해 접속 정보를 그쪽으로 돌리세요 (여러 버전을 함께 쓴다면 PGPORT로 18 쪽 포트를 지정)"
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

# world 속성 (2) — 데이터 (world_check.sql의 W1~W13).
if ! out=$(kit_psql -d "$DB" -X -q -v ON_ERROR_STOP=1 < world_check.sql 2>&1); then
  echo "$out" >&2
  echo "  (위 메시지의 W로 시작하는 번호는 world_check.sql의 검사 번호입니다 — world_check.sql에서 그 번호의 주석을 찾으면 무엇을 보는 검사인지 알 수 있습니다.)" >&2
  if [ "$KIT_MODE" = native ]; then
    fail "world 속성 검증 실패 — world(책숲)의 데이터가 초기 상태와 다릅니다" \
         "./reset.sh 로 world를 초기 상태로 되돌린 뒤 다시 실행하세요. 그래도 실패하면 dropdb $DB 로 데이터베이스를 지운 뒤 ./setup.sh 를 실행하세요 — setup.sh가 정렬 규칙을 고정해 다시 만들고 world를 seed.sql에서 적재합니다 (여기서 createdb로 직접 만들면 로케일이 서버 기본값이 되어 setup.sh가 막습니다)"
  else
    fail "world 속성 검증 실패 — world(책숲)의 데이터가 초기 상태와 다릅니다" \
         "./reset.sh 로 world를 초기 상태로 되돌린 뒤 다시 실행하세요. 그래도 실패하면 docker rm -f $KIT_CONTAINER 로 컨테이너를 지우고 ./setup.sh 를 실행하세요"
  fi
fi

echo "entry check 통과: PostgreSQL $ver, world(책숲) 적재·속성 확인 완료"
