# psql 실행 경로를 한 자리에 모은다 — 다른 스크립트가 `. ./kit_psql.sh`로 읽어들인다.
# 실행 파일이 아니라 공용 정의 파일이다.
#
# environment.md 「학습자 로컬 환경 요구사항」은 두 경로를 둔다.
#   기본 경로 (KIT_MODE=docker; 지정도 상태 파일도 없을 때의 기본값):
#     postgres:18 컨테이너 안의 psql을
#     docker exec로 실행한다. setup.sh가 컨테이너까지 만들어 준다.
#   대안 경로 (KIT_MODE=native): 학습자가 직접 설치한 PostgreSQL 18에
#     호스트의 psql로 접속한다. 접속 정보는 psql이 원래 읽는 환경 변수
#     (PGHOST·PGPORT·PGUSER·PGPASSWORD)를 그대로 쓴다 — kit가 따로
#     발명한 변수가 없어야 학습자가 자기 설치를 그대로 쓸 수 있다.
#
# 두 경로 모두 psql을 kit_psql로만 부른다. 인자는 psql에 그대로 전달되고
# 표준 입력도 그대로 이어진다.
#
# 환경 변수
#   KIT_MODE       docker | native (지정하지 않으면 아래 「구축 경로 기억」)
#   KIT_CONTAINER  컨테이너 이름 (docker 경로, 기본 ll-sql-fundamentals)
#   KIT_PORT       호스트 포트 (docker 경로의 -p 매핑, 기본 54321)
#   KIT_DB         데이터베이스 이름 (기본 bookstore)
#   KIT_PSQL       psql 실행 파일 (native 경로, 기본 psql)
#
# ## 구축 경로 기억 — KIT_MODE 미지정 시의 기본값
#
# `setup.sh`가 **구축에 실제로 쓴 경로**를 kit 디렉토리의 상태 파일
# `.kit-mode`(한 줄, `docker` 또는 `native`)에 적고, 이 파일이 KIT_MODE가
# 지정되지 않았을 때만 그것을 기본값으로 쓴다. 우선순위는
#   ① 환경 변수 KIT_MODE (지정하면 언제나 이긴다)
#   ② 상태 파일 .kit-mode (setup.sh가 마지막으로 구축한 경로)
#   ③ docker (상태 파일이 없을 때 — 아직 setup.sh를 돌리지 않았거나 지운 경우.
#      environment.md의 기본 경로이므로 종전 동작과 같다)
# 이다. 상태 파일의 내용이 docker/native가 아니면 조용히 넘어가지 않고 exit 2로
# 막는다 (원인과 다음 행동을 함께 낸다).
#
# **왜 이렇게 하는가.** 챕터 본문(11·12·13장)은 world를 되돌리는 자리에서
# `./reset.sh`를 맨 명령으로 40곳에 적고, 11장은 「그래야 책에 실린 결과와 같은
# 결과가 나옵니다」라고 못 박는다. 기본값이 무조건 docker이면, 대안 경로로
# 구축한 학습자가 새 터미널에서 그 40곳을 그대로 따를 때 kit는 있지도 않은
# 컨테이너를 보고 world를 되돌리지 못한다. 상태 파일을 두면 그 학습자는
# `KIT_MODE=native ./setup.sh`를 **한 번** 실행한 뒤로 챕터 본문의 맨 명령을
# 그대로 쓸 수 있고, 본문을 한 곳도 고치지 않아도 된다.
#
# 이것은 D-029(검증 러너 최소 규약)와 무관하다 — 케이스의 모양이 아니라 kit가
# 무엇을 어떻게 실행하는가, 즉 실행 환경 선택의 문제이고 D-029가 "가를 것"으로
# 둔 쪽에 속한다. 상태 파일은 학습자의 로컬 상태이지 산출물이 아니므로
# 저장소의 `.gitignore`가 추적에서 뺀다.
#
# 이 파일은 world의 **정렬 규칙(collation)** 판정 기준도 함께 정의한다
# (KIT_SORT_EXPECTED·kit_sort_probe). setup.sh와 check_env.sh가 같은 기준을
# 써야 하므로 한 자리에 둔다.

# 상태 파일은 이 파일(kit_psql.sh)이 있는 디렉토리에 둔다 — 어디서 부르든 같다.
KIT_STATE_FILE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/.kit-mode"

if [ -n "${KIT_MODE:-}" ]; then
  :   # ① 환경 변수 우선 — 지정한 KIT_MODE가 언제나 이긴다
elif [ -r "$KIT_STATE_FILE" ]; then
  KIT_MODE="$(tr -d '[:space:]' < "$KIT_STATE_FILE")"   # ② setup.sh가 구축한 경로
  case "$KIT_MODE" in
    docker|native) ;;
    *)
      echo "오류: 구축 경로 상태 파일의 내용이 docker/native가 아닙니다: '$KIT_MODE'" >&2
      echo "        파일: $KIT_STATE_FILE" >&2
      echo "  다음: 이 파일을 지운 뒤 ./setup.sh (대안 경로는 KIT_MODE=native ./setup.sh) 를 다시 실행하세요." >&2
      exit 2 ;;
  esac
else
  KIT_MODE=docker   # ③ 상태 파일 없음 — environment.md의 기본 경로
fi

# setup.sh가 구축에 성공했을 때 자기가 쓴 경로를 남긴다 (위 ②).
kit_state_save() { # $1=docker|native
  printf '%s\n' "$1" > "$KIT_STATE_FILE" 2>/dev/null \
    || echo "알림: 구축 경로를 $KIT_STATE_FILE 에 적지 못했습니다 — 다음부터는 명령 앞에 KIT_MODE=$1 를 붙여 실행하세요." >&2
}

KIT_CONTAINER="${KIT_CONTAINER:-ll-sql-fundamentals}"
KIT_PORT="${KIT_PORT:-54321}"
KIT_DB="${KIT_DB:-bookstore}"
KIT_PSQL="${KIT_PSQL:-psql}"

case "$KIT_MODE" in
  docker|native) ;;
  *) echo "오류: KIT_MODE=$KIT_MODE — docker 또는 native 여야 합니다." >&2; exit 2 ;;
esac

kit_psql() { # 인자는 psql 옵션. 표준 입력은 그대로 이어진다.
  if [ "$KIT_MODE" = native ]; then
    "$KIT_PSQL" "$@"
  else
    docker exec -i "$KIT_CONTAINER" psql -U postgres "$@"
  fi
}

# 경로별 접속 안내 한 줄 (실패 안내·구축 완료 안내에서 함께 쓴다).
kit_connect_hint() {
  if [ "$KIT_MODE" = native ]; then
    echo "psql -d $KIT_DB   (접속 정보는 PGHOST·PGPORT·PGUSER·PGPASSWORD로 지정)"
  else
    echo "docker exec -it $KIT_CONTAINER psql -U postgres -d $KIT_DB"
  fi
}

# ## 러너 동시 실행 보호 — 거절 (pipeline 「러너 최소 규약」 「러너는 동시 실행을 막는다」)
#
# 러너(verify.sh)는 하나의 world를 공유하고 변경형 케이스는 reset.sh로 그것을
# 되돌린다. 두 실행이 겹치면 한쪽의 리셋이 다른 쪽이 전제한 상태를 지워 결과가
# 비결정적이 된다 — 실측으로 같은 케이스 집합에 FAIL 13/88/5가 나왔고, 겹친 채로
# 돌린 reset.sh가 다른 세션의 락과 엉켜 bookstore 데이터베이스가 사라진 일이
# 있다. 위험은 FAIL이 아니라 거짓 PASS다.
#
# 택한 방식은 **거절**이다. 다른 러너가 돌고 있으면 기다리지 않고 원인·다음 행동을
# 내고 종료 코드 2로 끝낸다(조용히 기다리다 겹치는 것보다 낫다). reset.sh도 러너가
# 도는 동안에는 거절한다 — 러너 자신이 부르는 reset.sh만 통과시킨다(KIT_LOCK_HELD).
#
# 잠금은 **대상 world 단위**다 — 접속 방법이 아니라 서버(호스트:포트)와 DB 이름으로
# 식별한다. 기본 경로는 localhost:$KIT_PORT, 대안 경로는 PGHOST:PGPORT이므로 호스트
# psql로 같은 컨테이너에 붙는 대안 경로 러너도 같은 잠금을 본다(8차 K1). kit
# 디렉토리 단위가 아닌 이유: 실제 사고는 두 체크아웃(main과 worktree)이 같은
# 컨테이너를 쓰다 났다. 잠금은 /tmp에 두므로 저장소에 남지 않는다 — .kit-mode 같은
# 상태 파일이 아니라 실행 중에만 있는 것이다.
#
# 잠금이 보지 못하는 경우: 다른 머신·다른 사용자에서 온 접속, 같은 서버를 다른
# 호스트 표기(정규화하는 localhost·127.0.0.1·::1 외의 별칭)로 가리키는 접속,
# 러너를 거치지 않은 psql 세션. 그런 구성에서는 종전 규약대로 실행하는 쪽이
# 격리를 맡는다(실행 전 ps·pg_stat_activity 확인, 또는 전용 컨테이너).
#
# 구현은 mkdir의 원자성을 쓴다 — flock(1)은 macOS에 없다. 잠금 디렉토리 안에 소유
# 프로세스의 PID를 적어 두고, 그 프로세스가 없으면(정상 종료·인터럽트는 trap이
# 지우지만 kill -9는 못 지운다) 낡은 잠금으로 보고 걷어낸다.

kit_lock_key() { # 잠금이 식별하는 world: <호스트>:<포트>/<DB> — 접속 방법이 아니라 서버·DB
  local host port
  if [ "$KIT_MODE" = native ]; then
    host="${PGHOST:-localhost}"; port="${PGPORT:-5432}"
  else
    host=localhost; port="$KIT_PORT"     # setup.sh가 -p $KIT_PORT:5432 로 연다
  fi
  case "$host" in ""|localhost|127.0.0.1|::1) host=localhost ;; esac
  printf '%s:%s/%s' "$host" "$port" "$KIT_DB"
}

kit_lock_target() { # 사람에게 보여 줄 world 이름
  if [ "$KIT_MODE" = native ]; then
    kit_lock_key
  else
    printf '%s, 컨테이너 %s' "$(kit_lock_key)" "$KIT_CONTAINER"
  fi
}

kit_lock_path() {
  # 위치는 /tmp 고정이다 — TMPDIR을 쓰면 TMPDIR이 다른 셸(sudo·ssh·env -i)의
  # 러너가 서로를 보지 못한다 (8차 관찰 O12).
  printf '/tmp/learning-loop-kit-%s.lock' "$(kit_lock_key | tr -c 'A-Za-z0-9._-' '_')"
}

kit_lock_owner() { # 잠금을 쥔 살아 있는 프로세스의 PID. 없거나 낡았으면 빈 문자열.
  local dir pid
  dir="$(kit_lock_path)"
  [ -d "$dir" ] || { echo ""; return; }
  pid="$(cat "$dir/pid" 2>/dev/null || true)"
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then echo "$pid"; else echo ""; fi
}

kit_lock_acquire() { # verify.sh가 부른다. 다른 러너가 돌고 있으면 2로 종료.
  local dir owner
  dir="$(kit_lock_path)"
  if ! mkdir "$dir" 2>/dev/null; then
    owner="$(kit_lock_owner)"
    if [ -n "$owner" ]; then
      echo "오류: 다른 검증 러너(PID $owner)가 같은 world($(kit_lock_target))를 쓰고 있습니다 — 겹쳐 돌리면 결과가 비결정적이 됩니다 (거짓 PASS 위험)." >&2
      echo "  다음: 그 실행이 끝난 뒤 다시 실행하세요. 같이 돌려야 하면 KIT_CONTAINER=<새 이름> KIT_PORT=<새 포트> ./setup.sh 로 전용 컨테이너를 세운 뒤 같은 변수로 ./verify.sh 를 부르세요." >&2
      exit 2
    fi
    rm -rf "$dir"   # 소유 프로세스가 없는 낡은 잠금
    mkdir "$dir" 2>/dev/null \
      || { echo "오류: 잠금 디렉토리를 만들 수 없습니다: $dir" >&2
           echo "  다음: 그 경로의 권한을 확인하거나 TMPDIR 을 쓸 수 있는 디렉토리로 지정하세요." >&2; exit 2; }
  fi
  echo "$$" > "$dir/pid"
  KIT_LOCK_HELD="$$"; export KIT_LOCK_HELD
  # shellcheck disable=SC2064  # 지금의 경로를 굳혀 둔다
  trap "rm -rf '$dir'" EXIT
}

# world의 정렬 규칙(collation) — 두 경로가 **같은 차례의 표**를 내야 한다.
# 챕터 본문의 표는 한글 ORDER BY의 차례를 그대로 싣고 있으므로, 정렬 규칙이
# 갈리면 값은 같은데 줄의 차례가 달라진 표를 학습자가 보게 된다(9·11·12·13장).
#   기본 경로: setup.sh가 컨테이너를 -e LANG=C.UTF-8 로 초기화해 얻는다.
#   대안 경로: setup.sh가 bookstore를 builtin 제공자 C.UTF-8 로 만들어 얻는다.
#              (지정하지 않으면 학습자 서버의 기본값을 상속한다 — 전형값
#               en_US.UTF-8 에서는 '에세이'와 '요리'의 차례가 뒤바뀐다.)
#
# **판정은 메타데이터가 아니라 실제 정렬로 한다.** pg_database.datcollate 문자열
# 비교는 제공자가 다르면 어긋난다 — builtin 제공자로 만든 DB는 정렬이 C 차례인데도
# datcollate 에는 서버 기본값(en_US.utf8)이 그대로 남는다(실측).
#
# 프로브 대상은 books.category 8종의 리터럴 목록이다. 실제 열로 정렬한 결과
# (SELECT string_agg(c, ',' ORDER BY c) FROM (SELECT DISTINCT category c FROM books) t)
# 와 값이 같으면서, world를 아직 적재하지 않은 시점(CREATE DATABASE 직후)에도
# 쓸 수 있다.
KIT_SORT_EXPECTED='과학,소설,어린이,에세이,여행,역사,요리,자기계발'
KIT_SORT_PROBE_SQL="SELECT string_agg(c, ',' ORDER BY c) FROM (VALUES ('과학'),('소설'),('어린이'),('에세이'),('여행'),('역사'),('요리'),('자기계발')) v(c);"

kit_sort_probe() { # $1=데이터베이스 이름 → stdout: 그 DB의 실제 정렬 결과 한 줄
  kit_psql -d "$1" -X -tAc "$KIT_SORT_PROBE_SQL"
}
