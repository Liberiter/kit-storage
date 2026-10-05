# psql 실행 경로를 한 자리에 모은다 — 다른 스크립트가 `. ./kit_psql.sh`로 읽어들인다.
# 실행 파일이 아니라 공용 정의 파일이다.
#
# 이 코스는 두 경로를 둔다 (0장 0.1절 기본 경로·0.7절 대안 경로).
#   기본 경로 (KIT_MODE=docker; 지정도 상태 파일도 없을 때의 기본값):
#     postgres:18 컨테이너 안의 psql을 docker exec로 실행한다.
#     setup.sh가 컨테이너까지 만들어 준다.
#   대안 경로 (KIT_MODE=native): 직접 설치한 PostgreSQL 18에 호스트의 psql로
#     접속한다. 접속 정보는 psql이 원래 읽는 환경 변수(PGHOST·PGPORT·PGUSER·
#     PGPASSWORD)를 그대로 쓴다 — kit가 따로 발명한 변수가 없어야 자기 설치를
#     그대로 쓸 수 있다.
#
# 두 경로 모두 psql을 kit_psql로만 부른다. 인자는 psql에 그대로 전달되고
# 표준 입력도 그대로 이어진다.
#
# 환경 변수
#   KIT_MODE       docker | native (지정하지 않으면 아래 「구축 경로 기억」)
#   KIT_CONTAINER  컨테이너 이름 (docker 경로, 기본 ll-sql-advanced)
#   KIT_PORT       호스트 포트 (docker 경로의 -p 매핑, 기본 54323)
#   KIT_DB         world 데이터베이스 이름 (기본 bookstore_scale)
#   KIT_PSQL       psql 실행 파일 (native 경로, 기본 psql)
#   KIT_ADMIN_DB   world 를 지우고 다시 만들 때 붙는 관리용 데이터베이스 (기본 postgres)
#
# world 의 원본 데이터베이스는 "<KIT_DB>_template" 이다 (기본 bookstore_scale_template).
# setup.sh 가 world 를 한 번 만들어 이 이름으로 두고, reset.sh 는 그것을 통째로 복제해
# world 데이터베이스를 다시 만든다 (아래 「world 원본」).
#
# 앞 코스들의 kit과 **자원이 겹치지 않게** 기본값을 정했다 — fundamentals 는 컨테이너
# ll-sql-fundamentals·포트 54321·데이터베이스 bookstore, intermediate 는 ll-sql-intermediate·
# 54322·bookstore_ops 다. 세 kit을 같은 컴퓨터에 나란히 두고 써도 서로를 건드리지 않는다
# (대안 경로에서 한 서버를 함께 쓸 때도 데이터베이스 이름이 다르다).
#
# ## 구축 경로 기억 — KIT_MODE 미지정 시의 기본값
#
# `setup.sh`가 **구축에 실제로 쓴 경로**를 kit 디렉토리의 상태 파일
# `.kit-mode`(한 줄, `docker` 또는 `native`)에 적고, KIT_MODE가 지정되지 않았을
# 때만 그것을 기본값으로 쓴다. 우선순위는
#   ① 환경 변수 KIT_MODE (지정하면 언제나 이긴다)
#   ② 상태 파일 .kit-mode (setup.sh가 마지막으로 구축한 경로)
#   ③ docker (상태 파일이 없을 때 — 아직 setup.sh를 돌리지 않았거나 지운 경우)
# 이다. 상태 파일의 내용이 docker/native가 아니면 조용히 넘어가지 않고 exit 2로
# 막는다 (원인과 다음 행동을 함께 낸다).
#
# **왜 이렇게 하는가.** 챕터 본문은 world를 되돌리는 자리에서 `./reset.sh`를 맨
# 명령으로 적는다. 기본값이 무조건 docker이면, 대안 경로로 구축한 분이 새
# 터미널에서 그 명령을 그대로 따를 때 kit는 있지도 않은 컨테이너를 보고 world를
# 되돌리지 못한다. 상태 파일을 두면 `KIT_MODE=native ./setup.sh`를 **한 번**
# 실행한 뒤로 본문의 맨 명령을 그대로 쓸 수 있다.
#
# 상태 파일은 그 컴퓨터의 로컬 상태이지 kit의 내용물이 아니다 — 받은 kit 폴더에는
# 들어 있지 않고 ./setup.sh 가 구축에 성공할 때 생긴다.
#
# 이 파일은 world의 **정렬 규칙(collation)** 판정 기준(KIT_SORT_EXPECTED·kit_sort_probe),
# **세션 설정** 기준(KIT_SESSION_EXPECTED·kit_session_probe·kit_session_fix — 시간대·메시지
# 언어·날짜 표기·로케일·실수 표시 자릿수와 실행 계획을 가르는 설정), **psql 클라이언트 문구의
# 언어** 기준(KIT_CLIENT_EXPECTED·kit_client_probe — 고정은 kit_psql_native), **관찰 도구**
# 기준(kit_preload_ok — pg_stat_statements 가 서버에 올라와 있는가)과, 여러 스크립트가 공유하는
# **실행 전 점검**(kit_runtime_check·kit_connect_check), ~/.psqlrc 안내(kit_psqlrc_warn),
# 잠금(kit_lock_*)도 함께 정의한다. 실행 스크립트가 모두 같은 기준과 같은 문구를 써야 하므로
# 한 자리에 둔다.

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
  KIT_MODE=docker   # ③ 상태 파일 없음 — 이 코스의 기본 경로
fi

# setup.sh가 구축에 성공했을 때 자기가 쓴 경로를 남긴다 (위 ②).
kit_state_save() { # $1=docker|native
  printf '%s\n' "$1" > "$KIT_STATE_FILE" 2>/dev/null \
    || echo "알림: 구축 경로를 $KIT_STATE_FILE 에 적지 못했습니다 — 다음부터는 명령 앞에 KIT_MODE=$1 를 붙여 실행하세요." >&2
}

KIT_CONTAINER="${KIT_CONTAINER:-ll-sql-advanced}"
KIT_PORT="${KIT_PORT:-54323}"
KIT_DB="${KIT_DB:-bookstore_scale}"
KIT_PSQL="${KIT_PSQL:-psql}"
KIT_ADMIN_DB="${KIT_ADMIN_DB:-postgres}"
KIT_TEMPLATE_DB="${KIT_DB}_template"

case "$KIT_MODE" in
  docker|native) ;;
  *)
    echo "오류: KIT_MODE=$KIT_MODE — docker 또는 native 여야 합니다." >&2
    echo "  다음: KIT_MODE를 지우거나(unset KIT_MODE) docker/native 가운데 하나로 지정한 뒤 다시 실행하세요." >&2
    exit 2 ;;
esac

# 판정에 쓰는 비대화형 호출은 언제나 -X(= --no-psqlrc)다. 대안 경로에서 여러분의 ~/.psqlrc 에 `\timing on`·
# `\x auto`·`SET …` 같은 줄이 있으면, -X 없는 호출은 그 출력(「Timing is on.」「SET」 등)이 질의
# 결과에 섞여 버전 확인 같은 판정을 거짓 원인으로 깨뜨린다. 그래서 kit 스크립트는 psqlrc 를
# 읽지 않는다 — 바꿔 말해 kit 의 점검은 ~/.psqlrc 의 영향을 **보지 못한다**(check_env.sh 가 그
# 점을 따로 안내한다). -X 없이 psqlrc 를 읽는 비대화형 호출은 하나다 — psqlrc 가 여러분 세션을 바꾸는지
# 재는 kit_psqlrc_warn 의 프로브(대안 경로, 아래 「~/.psqlrc」)로, 바로 psqlrc 를 읽게 하는 것이 목적이다.
# 대화형 실행 kit_psql_tty 는 -X 를 붙이지 않는다 — psql.sh 가 여러분에게 여는 대화형 psql 이 그것이고,
# 여러분이 직접 여는 psql 과 같게 psqlrc 를 읽는다.
#
# 대안 경로의 psql 은 **클라이언트 로케일을 고정해** 부른다 (kit_psql_native). psql 자신이
# 내는 문구 — 결과표 끝의 행 수(`(5 rows)`), 접속 실패의 `psql: error:`, `\d` 표의 제목·열
# 이름 같은 것 — 는 서버의 lc_messages 가 아니라 **psql 을 실행한 쪽의 로케일**(LC_ALL →
# LC_MESSAGES → LANG, 그리고 LANGUAGE)을 따른다. 번역을 품은 psql(예: Homebrew
# postgresql@18)을 한국어 로케일에서 부르면 `(5개 행)`·`psql: 오류:` 가 나와, 서버 설정을 모두
# 고정했어도 대안 경로의 검증이 거의 전량 어긋난다. macOS 는 LANG 이 없어도 시스템 언어 설정을
# 따라 한국어가 된다.
#   고정값은 LC_ALL=C.UTF-8 이고 LANGUAGE 는 비운다. LC_MESSAGES=C 만 주는 것으로는 안 된다 —
#   LC_ALL 이 이기기 때문이다. C 가 아니라 C.UTF-8 인 까닭은 기본 경로의 컨테이너 psql 이 도는
#   LANG=C.UTF-8 과 같은 조건(문자 분류 UTF-8)을 두려는 것이다 — 터미널에 붙은 psql 은 LC_ALL=C 면
#   클라이언트 인코딩이 SQL_ASCII 가 되어 한글 표의 열 폭이 어긋난다.
#   이 고정은 kit 스크립트의 비대화형 호출(kit_psql·kit_psql_merged, sessions.sh 의 두 세션)에만
#   걸린다. 대안 경로에서는 대화형 kit_psql_tty 와 여러분이 직접 여는 psql 이 여러분 셸의 로케일을
#   따른다(기본 경로는 컨테이너 안의 psql 이라 LANG=C.UTF-8 로 영어다) — 그것은 여러분 세션만의
#   축이라 kit 이 판정하지 않는다. 고정이 실제로 먹는지는 check_env.sh 가 kit_client_probe 로 판정한다.
kit_psql_native() { # 인자는 psql 옵션 (-X 는 부르는 쪽이 붙인다)
  LC_ALL=C.UTF-8 LANGUAGE= "$KIT_PSQL" "$@"
}

kit_psql() { # 인자는 psql 옵션. 표준 입력은 그대로 이어진다.
  if [ "$KIT_MODE" = native ]; then
    kit_psql_native -X "$@"
  else
    docker exec -i "$KIT_CONTAINER" psql -X -U postgres "$@"
  fi
}

kit_psql_tty() { # 대화형(터미널 붙임) 실행 — psql.sh 가 쓴다.
  if [ "$KIT_MODE" = native ]; then
    "$KIT_PSQL" "$@"
  else
    docker exec -it "$KIT_CONTAINER" psql -U postgres "$@"
  fi
}

# kit_psql 과 같되 psql 의 표준 출력과 표준 오류를 «psql 쪽에서» 한 스트림으로 합쳐 낸다 —
# 출력의 줄 차례까지 대조하는 자리(verify.sh 의 케이스 대조, entry_check.sh 의 채점)가 쓴다.
# 기본 경로에서 `kit_psql … 2>&1` 처럼 호스트에서 합치면, docker exec 가 두 스트림을 따로
# 실어 날라 호스트에 닿는 차례가 보장되지 않는다 — 경고 줄(WARNING)이 결과표 위에 오기도 하고
# 아래에 오기도 해서 같은 입력이 실행마다 통과와 실패를 오갈 수 있다. 컨테이너 안에서 sh 가
# 합치면 psql 이 쓴 차례 그대로다. 대안 경로는 psql 이 호스트의 프로세스 하나라 호스트에서
# 합쳐도 같은 차례다. (sessions.sh 의 두 세션도 같은 까닭으로 같은 방법을 쓴다.)
# 기본 경로 끝의 2>&1 은 docker 명령 «자신의» 오류(도중에 컨테이너가 멈춘 경우 등)를 같은
# 출력에 담으려는 것이다 — psql 의 두 스트림은 이미 안에서 합쳐져 있어 그 차례에 끼어들지 않는다.
kit_psql_merged() { # 인자는 psql 옵션. 표준 입력은 그대로 이어진다.
  if [ "$KIT_MODE" = native ]; then
    kit_psql_native -X "$@" 2>&1
  else
    docker exec -i "$KIT_CONTAINER" sh -c 'exec psql -X -U postgres "$@" 2>&1' sh "$@" 2>&1
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

# ## 실행 전 점검 — 모든 스크립트가 같은 분기·같은 문구로 멈춘다
#
# kit_runtime_check <레이블> [종료 코드] : psql을 부르기 전에 경로별로 「무엇이 없는가」를
# 특정한다. 실패하면 「<레이블> 실패: 원인」 한 줄과 「다음: 할 일」 한 줄을 내고
# 종료 코드(기본 1)로 끝낸다. 검증 러너 verify.sh 와 두 세션 재현 sessions.sh 는 2를 넘긴다 —
# 그 스크립트들의 종료 코드 1은 「기대와 다른 결과」이고, 런타임·컨테이너·서버의 부재는 실행 오류다.
# 컨테이너를 만드는 setup.sh는 자기 분기를 따로 갖는다 (컨테이너가 없는 것이 그쪽에서는 정상이다).
#
# 기본 경로의 세 분기(docker 명령 없음 / 런타임 미실행 / 컨테이너 미실행)는 모두
# 대안 경로로 준비한 분을 위한 한 문장을 덧붙인다 — 상태 파일이 없어 기본 경로로
# 돌고 있을 뿐일 수 있기 때문이다.
KIT_NATIVE_HINT="대안 경로(네이티브 설치)로 준비하셨다면 KIT_MODE=native ./setup.sh 를 한 번 실행하세요 — 그 뒤로는 KIT_MODE 없이 그대로 쓰시면 됩니다"

kit_runtime_check() { # $1=레이블 (예: "reset", "entry check"), $2=종료 코드 (기본 1)
  local label="$1" rc="${2:-1}"
  if [ "$KIT_MODE" = native ]; then
    command -v "$KIT_PSQL" >/dev/null 2>&1 || {
      echo "$label 실패: psql 명령 없음 ($KIT_PSQL)" >&2
      echo "  다음: 0장 0.7절(대안 경로)대로 PostgreSQL 18을 설치하고 psql이 PATH에 있는지 확인하세요 (설치했는데 안 잡히면 KIT_PSQL=/설치경로/psql 로 지정)" >&2
      exit "$rc"; }
  else
    command -v docker >/dev/null 2>&1 || {
      echo "$label 실패: docker 명령 없음 (기본 경로로 실행 중)" >&2
      echo "  다음: 0장 0.1절대로 런타임을 설치하세요 (Windows: Docker Desktop / macOS: OrbStack / Linux: Docker Engine). $KIT_NATIVE_HINT" >&2
      exit "$rc"; }
    # 런타임 프로그램이 꺼져 있으면 docker ps 도 실패하므로, 컨테이너 검사보다 먼저
    # 데몬 접속을 확인해 원인이 「컨테이너 미실행」으로 잘못 나오지 않게 한다.
    docker info >/dev/null 2>&1 || {
      echo "$label 실패: 런타임 미실행 — docker 명령은 있지만 런타임 프로그램이 응답하지 않습니다 (기본 경로로 실행 중)" >&2
      echo "  다음: Windows는 Docker Desktop을 실행하고 Settings > Resources > WSL Integration에서 Ubuntu가 켜져 있는지 확인하세요 / macOS는 OrbStack을 실행하세요 / Linux는 sudo systemctl start docker 로 Docker 서비스를 시작하세요 (0장 0.1절). 그 뒤 ./setup.sh 를 다시 실행하세요 — 컨테이너를 다시 띄우고 world도 초기 상태로 되돌립니다. $KIT_NATIVE_HINT" >&2
      exit "$rc"; }
    docker ps --format '{{.Names}}' | grep -qx "$KIT_CONTAINER" || {
      echo "$label 실패: 컨테이너($KIT_CONTAINER) 미실행 (기본 경로로 실행 중)" >&2
      echo "  다음: ./setup.sh 를 먼저 실행하세요. $KIT_NATIVE_HINT" >&2
      exit "$rc"; }
  fi
}

# kit_connect_check <레이블> [종료 코드] : 실행 전 점검의 마지막 단계 — world 데이터베이스에
# 실제로 접속되는지를 한 번 확인한다. kit_runtime_check는 「명령·런타임·컨테이너가
# 있는가」까지만 보므로, 대안 경로에서 서버가 내려가 있으면(또는 접속 정보가 틀리면), 그리고
# 되돌리기가 중간에 멈춰 world 데이터베이스가 없으면 여기서 잡힌다.
kit_connect_check() { # $1=레이블, $2=종료 코드 (기본 1)
  local label="$1" rc="${2:-1}"
  kit_psql -d "$KIT_DB" -tAc "SELECT 1" >/dev/null 2>&1 && return 0
  if [ "$KIT_MODE" = native ]; then
    echo "$label 실패: psql 접속 불가 (데이터베이스 $KIT_DB)" >&2
    echo "  다음: PostgreSQL 서버가 떠 있는지(macOS Homebrew는 brew services start postgresql@18, Linux·WSL2는 sudo systemctl start postgresql), 접속 정보(PGHOST·PGPORT·PGUSER·PGPASSWORD — Linux·WSL2는 PGHOST=localhost까지)가 맞는지 확인한 뒤 ./setup.sh 를 실행하세요 — world 데이터베이스가 없으면 setup.sh 가 다시 만듭니다" >&2
  else
    echo "$label 실패: psql 접속 불가 (컨테이너 $KIT_CONTAINER, 데이터베이스 $KIT_DB)" >&2
    echo "  다음: ./setup.sh 를 다시 실행하세요 — world 데이터베이스가 없으면 다시 만듭니다. 그래도 같으면 docker logs $KIT_CONTAINER 로 서버 상태를 확인하세요" >&2
  fi
  exit "$rc"
}

# ## 러너 동시 실행 보호 — 거절
#
# 러너(verify.sh)는 하나의 world를 공유하고 변경형 케이스는 reset.sh로 그것을
# 되돌린다. 두 실행이 겹치면 한쪽의 리셋이 다른 쪽이 전제한 상태를 지워 결과가
# 비결정적이 된다. 위험은 FAIL이 아니라 거짓 PASS다.
#
# 택한 방식은 **거절**이다. 다른 실행이 돌고 있으면 기다리지 않고 원인·다음 행동을
# 내고 종료 코드 2로 끝낸다(조용히 기다리다 겹치는 것보다 낫다). reset.sh도 그런 실행이
# 도는 동안에는 거절한다 — 그 실행 자신이 부르는 reset.sh만 통과시킨다(KIT_LOCK_HELD).
# 같은 잠금을 잡는 스크립트: verify.sh·entry_check.sh·sessions.sh·measure.sh·workload.sh.
# (measure.sh·workload.sh 는 world 를 바꾸지 않지만, 도중에 다른 실행이 world 를 다시 만들면
# 재던 값이 엉뚱해지므로 함께 잡는다.)
#
# 잠금은 **대상 world 단위**다 — 접속 방법이 아니라 서버(호스트:포트)와 DB 이름으로
# 식별한다. 기본 경로는 localhost:$KIT_PORT, 대안 경로는 PGHOST:PGPORT이므로 호스트
# psql로 같은 컨테이너에 붙는 대안 경로 실행도 같은 잠금을 본다. 앞 코스 kit들의
# 잠금과는 키가 다르므로 코스끼리는 서로 막지 않는다.
# 잠금은 /tmp에 두므로 kit 폴더에 남지 않는다 — 실행 중에만 있는 것이다.
#
# 잠금이 보지 못하는 경우: 다른 머신·다른 사용자에서 온 접속, 같은 서버를 다른
# 호스트 표기(정규화하는 localhost·127.0.0.1·::1 외의 별칭)로 가리키는 접속,
# 러너를 거치지 않은 psql 세션. 그런 구성에서는 실행하는 쪽이 격리를 맡는다
# (실행 전 ps·pg_stat_activity 확인, 또는 전용 컨테이너).
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
  # 실행이 서로를 보지 못한다.
  printf '/tmp/learning-loop-kit-%s.lock' "$(kit_lock_key | tr -c 'A-Za-z0-9._-' '_')"
}

kit_lock_owner() { # 잠금을 쥔 살아 있는 프로세스의 PID. 없거나 낡았으면 빈 문자열.
  local dir pid
  dir="$(kit_lock_path)"
  [ -d "$dir" ] || { echo ""; return; }
  pid="$(cat "$dir/pid" 2>/dev/null || true)"
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then echo "$pid"; else echo ""; fi
}

kit_lock_acquire() { # 다른 실행이 있으면 2로 종료.
  local dir owner
  dir="$(kit_lock_path)"
  if ! mkdir "$dir" 2>/dev/null; then
    owner="$(kit_lock_owner)"
    if [ -n "$owner" ]; then
      echo "오류: 같은 world($(kit_lock_target))를 쓰는 다른 실행(PID $owner)이 있습니다 — 겹쳐 돌리면 두 실행이 서로의 데이터를 되돌려, 맞지 않는 결과가 통과로 나올 수 있습니다." >&2
      echo "  다음: 그 실행이 끝난 뒤 다시 실행하세요. 같이 돌려야 하면 KIT_CONTAINER=<새 이름> KIT_PORT=<새 포트> ./setup.sh 로 전용 컨테이너를 세운 뒤 같은 변수로 다시 부르세요." >&2
      exit 2
    fi
    rm -rf "$dir"   # 소유 프로세스가 없는 낡은 잠금
    mkdir "$dir" 2>/dev/null \
      || { echo "오류: 잠금 디렉토리를 만들 수 없습니다: $dir" >&2
           echo "  다음: 그 경로의 권한을 확인하세요 (/tmp 에 쓸 수 있어야 합니다)." >&2; exit 2; }
  fi
  echo "$$" > "$dir/pid"
  KIT_LOCK_HELD="$$"; export KIT_LOCK_HELD
  KIT_LOCK_DIR="$dir"
  # shellcheck disable=SC2064  # 지금의 경로를 굳혀 둔다
  trap "rm -rf '$dir'" EXIT
  # 이 뒤에 자기 EXIT trap 을 거는 스크립트는 그 안에서 kit_lock_release 를 함께 불러야 한다
  # — trap 은 덮어쓰기라 잠금이 남는다 (sessions.sh 가 그 예).
}

kit_lock_release() { [ -n "${KIT_LOCK_DIR:-}" ] && rm -rf "$KIT_LOCK_DIR"; }

# ## world 원본 — 템플릿 데이터베이스
#
# 이 코스의 world 는 수백 MB 다(판매 150만 건 등). 되돌릴 때마다 데이터를 새로 만들면 몇십 초가
# 걸리므로, setup.sh 가 world 를 한 번 만들어 원본 데이터베이스(KIT_TEMPLATE_DB)로 두고 reset.sh 는
# 그것을 파일째 복제해(CREATE DATABASE … TEMPLATE … STRATEGY FILE_COPY) world 데이터베이스를 다시
# 만든다 — 1~3초. 복제는 데이터만이 아니라 **통계·가시성 맵·행이 놓인 페이지 자리**까지 그대로
# 옮기므로, 되돌린 직후의 world 는 언제나 같은 물리 상태다(뒷정리와 통계 수집이 끝난 정착 상태).
# 원본은 접속을 막아 둔다(ALLOW_CONNECTIONS false) — 누가 붙어 있으면 복제가 실패하기 때문이다.
#
# 원본이 어떤 kit 파일로 만들어졌는지는 원본 데이터베이스의 설명(COMMENT)에 적어 둔다
# (kit_world_stamp). setup.sh 는 설명이 지금 kit 파일과 다를 때만 원본을 다시 만든다.
KIT_WORLD_FILES="schema.sql seed_ref.sql seed.sql seed_ops.sql legacy.sql antipatterns.sql scale_schema.sql seed_scale.sql theory.sql"
KIT_WORLD_FORMAT=1   # 원본을 만드는 절차(setup.sh)가 바뀌면 올린다 — 설명이 달라져 원본을 다시 만든다

kit_world_stamp() { # stdout: "world v<형식> <cksum 값> <바이트 수>" — 파일이 하나라도 없으면 반환 1
  local f
  for f in $KIT_WORLD_FILES; do [ -r "$f" ] || return 1; done
  # shellcheck disable=SC2086  # 파일 이름 목록을 낱말로 나눈다
  printf 'world v%s %s' "$KIT_WORLD_FORMAT" "$(cat $KIT_WORLD_FILES | cksum | tr -s ' ' | sed 's/ $//')"
}

kit_template_exists() { # 0 이면 원본 데이터베이스가 있다
  [ "$(kit_psql -d "$KIT_ADMIN_DB" -tAc "SELECT 1 FROM pg_database WHERE datname = '$KIT_TEMPLATE_DB'" 2>/dev/null)" = "1" ]
}

# world의 정렬 규칙(collation) — 두 경로가 **같은 차례의 표**를 내야 한다.
# 챕터 본문의 표는 한글 ORDER BY의 차례를 그대로 싣고 있으므로, 정렬 규칙이
# 갈리면 값은 같은데 줄의 차례가 달라진 표를 보게 된다. 앞 코스들과 같은 차례(코드포인트 차례)다.
# 이 코스는 두 경로 모두 setup.sh 가 원본 데이터베이스를 **같은 문장으로** 만든다 — builtin 제공자
# C.UTF-8, libc 쪽 LC_COLLATE·LC_CTYPE 은 C (복제한 world 는 원본의 설정을 그대로 물려받는다).
# 그래서 정렬 차례뿐 아니라, 앞부분이 정해진 LIKE('abc%')가 보통의 B-tree 인덱스를 범위로 쓸 수
# 있는지도 두 경로가 같다(C 차례의 정렬 규칙에서만 그 변환이 일어난다). 앞 코스들의 기본 경로는
# 컨테이너의 기본 로케일(libc C.UTF-8)을 물려받아, 같은 질의가 그 데이터베이스에서는 Seq Scan 이었다.
#
# **판정은 메타데이터가 아니라 실제 정렬로 한다.** pg_database.datcollate 문자열
# 비교는 제공자가 다르면 어긋난다 — builtin 제공자로 만든 DB는 정렬이 C 차례인데도
# datcollate 에는 지정한 libc 값이 따로 남는다.
#
# 프로브 대상은 books.category 8종의 리터럴 목록이다. world를 아직 적재하지 않은
# 시점(CREATE DATABASE 직후)에도 쓸 수 있다.
KIT_SORT_EXPECTED='과학,소설,어린이,에세이,여행,역사,요리,자기계발'
KIT_SORT_PROBE_SQL="SELECT string_agg(c, ',' ORDER BY c) FROM (VALUES ('과학'),('소설'),('어린이'),('에세이'),('여행'),('역사'),('요리'),('자기계발')) v(c);"

kit_sort_probe() { # $1=데이터베이스 이름 → stdout: 그 DB의 실제 정렬 결과 한 줄
  kit_psql -d "$1" -X -tAc "$KIT_SORT_PROBE_SQL"
}

# world의 **세션 설정** — 정렬 규칙과 같은 취급이다. 데이터베이스 설정(ALTER DATABASE … SET)으로
# 못 박아, 두 경로가 같은 출력을 내게 하고 여러분의 대화형 psql 세션에도 같은 값이 걸리게 한다.
# 판정은 접속한 세션의 실제 값(current_setting)으로 한다. 두 묶음이다.
#
# (1) 표시·해석 — 앞 코스와 같은 일곱 값.
#   timezone=UTC          timestamptz 는 세션 시간대로 표시된다. 직접 설치한 서버는 컴퓨터의 시간대
#                         (예: Asia/Seoul)를 기본값으로 잡아 +09 로 표시한다.
#   lc_messages=C         서버 오류 메시지의 언어 (서버 로케일을 따르면 한국어가 될 수 있다).
#   DateStyle='ISO, MDY'  '01/02/2026' 같은 날짜 입력의 해석 (ko_KR 서버는 'iso, ymd').
#   lc_monetary·lc_numeric·lc_time=C   to_char 의 통화 기호·자릿수 구분·요일 이름.
#   extra_float_digits=1  실수형 값을 찍는 자릿수 (0 이하면 반올림한 옛 표기).
#
# (2) 실행 계획과 그 출력 — 이 코스가 실행 계획을 읽는 코스라서 더했다. PostgreSQL 의 기본값으로
#     못 박는다(jit 만 예외). 여러분이 설치한 서버의 설정 파일이 이 값을 바꿔 두었어도 이 데이터베이스
#     에서는 교재와 같은 계획 후보·비용 어림·메모리 한도로 돈다. 한 세션에서 SET 으로 바꿔 실험하는
#     것은 그대로 할 수 있다.
#   jit=off               JIT 컴파일은 서버 빌드에 따라 있기도 없기도 하다(컨테이너의 이미지에는 있고,
#                         Homebrew 판에는 없다). 켜 두면 큰 질의의 EXPLAIN ANALYZE 끝에 JIT 블록이 붙는
#                         서버와 붙지 않는 서버가 갈리므로 끈다. JIT 자체는 이 코스가 다루지 않는다.
#   work_mem=4MB · hash_mem_multiplier=2 · maintenance_work_mem=64MB   정렬·해시가 메모리를 넘어
#                         디스크로 넘치는 경계.
#   effective_cache_size=4GB · random_page_cost=4 · seq_page_cost=1 · cpu_tuple_cost=0.01 ·
#   cpu_index_tuple_cost=0.005 · cpu_operator_cost=0.0025   플래너의 비용 어림에 들어가는 값.
#   max_parallel_workers_per_gather=2 · max_parallel_workers=8 · parallel_setup_cost=1000 ·
#   parallel_tuple_cost=0.1 · min_parallel_table_scan_size=8MB · min_parallel_index_scan_size=512kB
#                         병렬 계획의 후보와 작업자 수.
#   default_statistics_target=100   ANALYZE 가 남기는 통계의 크기.
#   track_io_timing=off   켜면 EXPLAIN (ANALYZE, BUFFERS) 에 I/O 시간 줄이 더 붙는다.
#   default_toast_compression=pglz   큰 값의 압축 방식 (빌드에 따라 lz4 를 기본으로 바꿔 둔 서버가 있다).
#
# 고정하지 **못하는** 값도 있다 — shared_buffers 는 서버를 시작할 때 정해지는 값이라 데이터베이스
# 설정으로 바꿀 수 없다. 기본 경로는 컨테이너를 128MB 로 띄우고, check_env.sh 는 대안 경로 서버의
# 값이 다르면 알림만 낸다 (kit_shared_buffers_probe).
#
# psql 쪽 환경 변수 PGTZ·PGDATESTYLE·PGOPTIONS 와 ALTER ROLE … SET 은 데이터베이스 설정을 이기고
# kit 의 프로브에도 그대로 걸리므로, check_env.sh 가 불일치를 보면 그것들을 안내한다. ~/.psqlrc 의
# SET 은 다르다 — kit 의 판정 호출은 전부 -X 라 psqlrc 를 읽지 않으므로 프로브에 걸리지 않고 여러분의
# 대화형 세션에만 작용한다. check_env.sh 는 대안 경로에서 psqlrc 를 읽는 세션의 실제 값을 따로 재어
# (아래 「~/.psqlrc」) 다르면 「알림」을 낸다(판정은 바꾸지 않는다).
KIT_SESSION_NAMES='timezone|lc_messages|DateStyle|lc_monetary|lc_numeric|lc_time|extra_float_digits|jit|work_mem|hash_mem_multiplier|maintenance_work_mem|effective_cache_size|random_page_cost|seq_page_cost|cpu_tuple_cost|cpu_index_tuple_cost|cpu_operator_cost|max_parallel_workers_per_gather|max_parallel_workers|parallel_setup_cost|parallel_tuple_cost|min_parallel_table_scan_size|min_parallel_index_scan_size|default_statistics_target|track_io_timing|default_toast_compression'
KIT_SESSION_EXPECTED='UTC|C|ISO, MDY|C|C|C|1|off|4MB|2|64MB|4GB|4|1|0.01|0.005|0.0025|2|8|1000|0.1|8MB|512kB|100|off|pglz'
KIT_SESSION_PROBE_SQL_BARE="SELECT concat_ws('|', current_setting('TimeZone'), current_setting('lc_messages'), current_setting('DateStyle'), current_setting('lc_monetary'), current_setting('lc_numeric'), current_setting('lc_time'), current_setting('extra_float_digits'), current_setting('jit'), current_setting('work_mem'), current_setting('hash_mem_multiplier'), current_setting('maintenance_work_mem'), current_setting('effective_cache_size'), current_setting('random_page_cost'), current_setting('seq_page_cost'), current_setting('cpu_tuple_cost'), current_setting('cpu_index_tuple_cost'), current_setting('cpu_operator_cost'), current_setting('max_parallel_workers_per_gather'), current_setting('max_parallel_workers'), current_setting('parallel_setup_cost'), current_setting('parallel_tuple_cost'), current_setting('min_parallel_table_scan_size'), current_setting('min_parallel_index_scan_size'), current_setting('default_statistics_target'), current_setting('track_io_timing'), current_setting('default_toast_compression'))"
KIT_SESSION_PROBE_SQL="$KIT_SESSION_PROBE_SQL_BARE;"

kit_session_probe() { # $1=데이터베이스 이름 → stdout: KIT_SESSION_NAMES 차례의 값들을 | 로 이은 한 줄
  kit_psql -d "$1" -X -tAc "$KIT_SESSION_PROBE_SQL"
}

kit_session_fix() { # $1=데이터베이스 이름 → 그 DB의 기본 세션 설정을 고정한다 (멱등). 관리용 DB 에 붙어 실행한다.
  kit_psql -d "$KIT_ADMIN_DB" -X -q -v ON_ERROR_STOP=1 <<EOF_FIX
ALTER DATABASE "$1" SET timezone TO 'UTC';
ALTER DATABASE "$1" SET lc_messages TO 'C';
ALTER DATABASE "$1" SET DateStyle TO 'ISO, MDY';
ALTER DATABASE "$1" SET lc_monetary TO 'C';
ALTER DATABASE "$1" SET lc_numeric TO 'C';
ALTER DATABASE "$1" SET lc_time TO 'C';
ALTER DATABASE "$1" SET extra_float_digits TO 1;
ALTER DATABASE "$1" SET jit TO off;
ALTER DATABASE "$1" SET work_mem TO '4MB';
ALTER DATABASE "$1" SET hash_mem_multiplier TO 2;
ALTER DATABASE "$1" SET maintenance_work_mem TO '64MB';
ALTER DATABASE "$1" SET effective_cache_size TO '4GB';
ALTER DATABASE "$1" SET random_page_cost TO 4;
ALTER DATABASE "$1" SET seq_page_cost TO 1;
ALTER DATABASE "$1" SET cpu_tuple_cost TO 0.01;
ALTER DATABASE "$1" SET cpu_index_tuple_cost TO 0.005;
ALTER DATABASE "$1" SET cpu_operator_cost TO 0.0025;
ALTER DATABASE "$1" SET max_parallel_workers_per_gather TO 2;
ALTER DATABASE "$1" SET max_parallel_workers TO 8;
ALTER DATABASE "$1" SET parallel_setup_cost TO 1000;
ALTER DATABASE "$1" SET parallel_tuple_cost TO 0.1;
ALTER DATABASE "$1" SET min_parallel_table_scan_size TO '8MB';
ALTER DATABASE "$1" SET min_parallel_index_scan_size TO '512kB';
ALTER DATABASE "$1" SET default_statistics_target TO 100;
ALTER DATABASE "$1" SET track_io_timing TO off;
ALTER DATABASE "$1" SET default_toast_compression TO 'pglz';
EOF_FIX
}

# shared_buffers — 서버를 시작할 때 정해져 데이터베이스 설정으로는 못 박지 못한다. 공유 버퍼에서
# 찾았는지(hit) 못 찾았는지(read)의 셈이 이 크기에 걸린다. 기본 경로는 128MB 로 띄운다.
KIT_SHARED_BUFFERS_EXPECTED='128MB'
kit_shared_buffers_probe() { # $1=데이터베이스 → stdout: SHOW shared_buffers
  kit_psql -d "$1" -X -tAc "SHOW shared_buffers;"
}

# 관찰 도구 — pg_stat_statements 는 서버가 시작할 때 라이브러리를 올려 두어야(shared_preload_libraries)
# 쓸 수 있다. 확장(CREATE EXTENSION)은 원본 데이터베이스에 들어 있어 복제한 world 에도 있다. 여기서는
# 서버 쪽 — 라이브러리가 올라와 있는가 — 를 본다. 나머지 관찰 도구(pageinspect·pg_buffercache·
# pgstattuple·pg_visibility)는 확장을 만들기만 하면 쓸 수 있어 서버 설정이 필요 없다.
kit_preload_ok() { # $1=데이터베이스 → 0 이면 pg_stat_statements 가 올라와 있다
  [ "$(kit_psql -d "$1" -X -tAc "SELECT 'pg_stat_statements' = ANY (string_to_array(replace(current_setting('shared_preload_libraries'), ' ', ''), ','))" 2>/dev/null)" = "t" ]
}

# psql **클라이언트** 문구의 언어 — 위 세션 설정(서버 쪽)과 다른 축이다 (kit_psql_native 주석).
# kit 이 부르는 psql 이 결과표 끝에 영어 행 수를 내는지로 판정한다. 기본 경로는 컨테이너 안
# psql(LANG=C.UTF-8), 대안 경로는 kit_psql_native 의 고정이 그것을 보장해야 한다.
KIT_CLIENT_EXPECTED='(1 row)'
kit_client_probe() { # $1=데이터베이스 이름 → stdout: 결과표의 비지 않은 마지막 줄 (행 수 줄)
  # psql 은 행 수 줄 뒤에 빈 줄을 하나 더 찍으므로 tail -n 1 이 아니라 비지 않은 마지막 줄을 고른다.
  kit_psql -d "$1" -X -c "SELECT 1 AS probe;" 2>/dev/null | awk 'NF { last = $0 } END { print last }'
}

# world의 **libc 문자 분류(LC_CTYPE)** — 세션 설정이 아니라 데이터베이스를 만들 때 정해지는
# 성질이라 ALTER 로 고칠 수 없다. 복제한 world 는 원본의 값을 물려받는다.
#
# 이 축은 **값을 글자 단위로 어떻게 읽을지**를 정한다. 대소문자 변환(upper·lower)·정규식의 문자
# 클래스·대소문자를 무시하는 비교(ILIKE·~*)는 그 데이터베이스의 **제공자와 그 로케일**이 맡는다
# — 이 world 는 builtin 제공자 C.UTF-8 이라 그것이 맡는다. **LC_CTYPE 에만 매인 것**으로 확인된 것은
# 행 전체를 한 값으로 찍는 출력(`ROW(…)::text`, `SELECT t FROM 테이블 t`)의 인용 판정(libc isspace())과
# \l 이 내는 Ctype 열의 값이다 — macOS libc 는 UTF-8 로케일에서 바이트 0xA0 을 공백으로 보아, UTF-8
# 바이트에 0xA0 이 든 한글(`신`·`고` 등)이 그런 출력에서 따옴표로 감싸인다. 그 밖의 자리가 더 있을 수 있다.
#
# setup.sh 는 두 경로 모두 원본을 LC_CTYPE 'C' 로 만든다 — 그래서 이 코스의 world 는 두 경로의 값이
# 같다. check_env.sh 는 world 의 값이 C 계열이 아니면(다른 방법으로 만든 원본) 알림만 낸다.
KIT_CTYPE_PROBE_SQL_PREFIX="SELECT datctype FROM pg_database WHERE datname = "

kit_ctype_probe() { # $1=데이터베이스 이름 → stdout: 그 DB의 datctype 한 줄
  kit_psql -d "$1" -X -tAc "${KIT_CTYPE_PROBE_SQL_PREFIX}'$1';"
}

# 허용 값과 화면 문구(KIT_CTYPE_EXPECTED_TEXT)는 한 쌍이다 — 한쪽을 고치면 다른 쪽도 고친다.
KIT_CTYPE_EXPECTED_TEXT='C 계열 — C, POSIX, C.UTF-8(C.utf8)'
kit_ctype_ok() { # $1=datctype 값 → 0 이면 기대 범위
  case "$1" in C|POSIX|C.UTF-8|C.utf8) return 0 ;; *) return 1 ;; esac
}

# ## ~/.psqlrc — kit 점검 밖에 있는 축의 안내 (대안 경로)
#
# kit 의 판정 호출은 전부 -X 라 psqlrc 를 읽지 않는다. 그래서 psqlrc 의 `SET timezone …`·
# `SET work_mem …` 같은 줄은 kit 의 세션 설정 판정을 통과시키면서 여러분의 대화형 세션만 본문과
# 다르게 만든다(예: timestamptz 가 +09 로 표시되거나 실행 계획이 달라진다).
#
# 재는 방법: psqlrc 를 **읽는** psql 로 `\copy (SELECT current_setting(…)) TO <임시 파일>` 을
# 실행한다. `\copy` 는 표시 설정·`\timing`·`\x auto`·`\set QUIET`·`\o` 와 무관하게 값만 파일에
# 쓰므로 psqlrc 가 적용된 세션의 실제 값을 정확히 얻는다. 그 값이 kit 자신의 -X 프로브 값과 다르면
# psqlrc(또는 psql 이 시동 때 읽는 무엇)가 여러분 세션을 바꾸는 것이다 — 그때 **알림**을 내고, 어느
# 파일의 어느 줄인지 함께 보인다. 판정·종료 코드는 바꾸지 않는다(데이터베이스 설정은 맞고, 고칠
# 자리는 여러분의 psqlrc 이므로). 기본 경로는 컨테이너 안 psql 이 호스트 psqlrc 를 읽지 않으므로
# 해당 없다.
#
# psql 이 읽는 파일(읽는 차례; 각 묶음에서 처음 있는 것 하나만 읽는다):
#   시스템: <sysconfdir>/psqlrc-<PG_VERSION> → psqlrc-<메이저> → psqlrc   (sysconfdir 는 psql 옆의 pg_config)
#   사용자: <base>-<PG_VERSION> → <base>-<메이저> → <base>                (base = $PSQLRC 또는 ~/.psqlrc)
# <PG_VERSION> 은 `psql -V` 가 「psql (PostgreSQL) 」 뒤에 찍는 **문자열 전부**다 — 빌드에 따라 접미가 붙는다
# (Homebrew postgresql@18: `18.6 (Homebrew)`, Debian/PGDG: `18.6 (Debian 18.6-1.pgdg13+2)`).
# `18.6` 만 잘라 쓰면 psql 이 읽지 않는 파일을 가리키게 된다. 그래서 이름에 공백·괄호가 들어갈 수
# 있고, 목록은 줄 단위로 다룬다(단어 분리 금지). 프로브가 실패하면 파일 검사만으로 알림을 낸다.
kit_psqlrc_version() { # stdout: psql 의 PG_VERSION 전체 문자열 (예: "18.6 (Homebrew)"), 실패 시 빈 줄
  "$KIT_PSQL" -V 2>/dev/null | sed -n 's/^psql (PostgreSQL) //p' | head -1 || true
}

kit_psqlrc_files() { # stdout: psql 이 실제로 읽을 psqlrc 파일 경로들, 한 줄에 하나 (없으면 빈 출력). 언제나 0 을 반환한다.
  local ver major base sysdir pgc f
  ver=$(kit_psqlrc_version)
  major=$(printf '%s' "$ver" | sed -nE 's/^([0-9]+).*/\1/p')
  pgc="$(dirname "$(command -v "$KIT_PSQL" 2>/dev/null || echo /nonexistent)")/pg_config"
  if [ ! -x "$pgc" ]; then pgc="$(command -v pg_config 2>/dev/null || true)"; fi
  sysdir=""
  if [ -n "$pgc" ]; then sysdir=$("$pgc" --sysconfdir 2>/dev/null || true); fi
  if [ -n "$sysdir" ]; then
    for f in "$sysdir/psqlrc-$ver" "$sysdir/psqlrc-$major" "$sysdir/psqlrc"; do
      if [ -n "$ver" ] || [ "$f" = "$sysdir/psqlrc" ]; then
        if [ -r "$f" ]; then printf '%s\n' "$f"; break; fi
      fi
    done
  fi
  base="${PSQLRC:-$HOME/.psqlrc}"
  for f in "$base-$ver" "$base-$major" "$base"; do
    if [ -n "$ver" ] || [ "$f" = "$base" ]; then
      if [ -r "$f" ]; then printf '%s\n' "$f"; break; fi
    fi
  done
  return 0
}

kit_psqlrc_warn() { # 언제나 0 을 반환한다 — 알림일 뿐 판정이 아니다 (호출자는 set -e).
  if [ "$KIT_MODE" != native ]; then return 0; fi
  local files tmp actual mine hits f h line
  files=$(kit_psqlrc_files || true)
  # psqlrc 를 읽는 세션의 실제 값 (-X 없음). 실패하면 빈 문자열.
  tmp=$(mktemp "${TMPDIR:-/tmp}/ll-kit-psqlrc.XXXXXX" 2>/dev/null || true)
  actual=""
  if [ -n "$tmp" ]; then
    # stdin 은 /dev/null — psqlrc 에 \prompt 가 있으면 psql 이 터미널 입력을 기다리며 말없이 멈춘다. 입력이 닫혀 있으면
    # \prompt 는 오류 한 줄을 내고 변수를 설정하지 않은 채 다음 줄로 진행하며 프로브는 값을 낸다 (그 오류 줄은 아래 2>&1 에 가려 화면에 나오지 않는다).
    "$KIT_PSQL" -d "$KIT_DB" -qAt -c "\\copy ($KIT_SESSION_PROBE_SQL_BARE) TO '$tmp'" </dev/null >/dev/null 2>&1 || true
    actual=$(tr -d '\n' < "$tmp" 2>/dev/null || true)
    rm -f "$tmp"
  fi
  mine=$(kit_session_probe "$KIT_DB" 2>/dev/null || true)
  hits=""
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    h=$(command grep -inE '^[[:space:]]*set[[:space:]]+(timezone|time zone|datestyle|lc_messages|lc_monetary|lc_numeric|lc_time|extra_float_digits|jit|work_mem|hash_mem_multiplier|maintenance_work_mem|effective_cache_size|random_page_cost|seq_page_cost|cpu_[a-z_]*cost|max_parallel_workers[a-z_]*|parallel_[a-z_]*cost|min_parallel_[a-z_]*|default_statistics_target|track_io_timing|default_toast_compression|enable_[a-z_]*)\b' "$f" 2>/dev/null || true)
    [ -n "$h" ] || continue
    while IFS= read -r line; do hits="$hits$f:$line"$'\n'; done <<EOF_H
$h
EOF_H
  done <<EOF_F
$files
EOF_F
  if [ -n "$actual" ]; then
    if [ "$actual" = "$mine" ]; then return 0; fi          # 세션이 같으면 psqlrc 는 세션 설정을 바꾸지 않는다
  else
    if [ -z "$hits" ]; then return 0; fi                   # 프로브 실패 — 파일에 SET 줄이 있을 때만
  fi
  echo "알림: psqlrc 가 여러분의 psql 세션 설정을 바꿉니다 — kit 점검은 psqlrc 를 읽지 않으므로(-X) 이것은 판정에 들어가지 않지만, 여러분이 직접 여는 psql 세션은 교재 본문과 다르게 보일 수 있습니다(timestamptz 표시·날짜 입력 해석·to_char 출력·실수 값의 자릿수·실행 계획)." >&2
  if [ -n "$actual" ]; then echo "        psqlrc 적용 후 여러분 세션 ($KIT_SESSION_NAMES): $actual  (코스 기대값: $KIT_SESSION_EXPECTED)" >&2; fi
  if [ -n "$files" ]; then printf '%s\n' "$files" | sed 's/^/        psql 이 읽는 파일: /' >&2; fi
  if [ -n "$hits" ]; then printf '%s' "$hits" | sed 's/^/        /' >&2; fi
  echo "        다음: 이 코스를 진행하는 동안 그 SET 줄을 지우거나 주석(--)으로 바꾸세요. 임시로는 psql -X 로 열어도 됩니다." >&2
  return 0
}
