# 바람재 관측망 kit의 공용 정의입니다. 다른 스크립트가 맨 앞에서 읽어 들입니다.
# 직접 실행하는 파일이 아닙니다.
#
# 여기에 모아 둔 것:
#   - 두 경로(uv / venv)를 가르는 자리와 파이썬을 부르는 한 가지 방법
#   - 구축 경로 기억 (.kit-mode)
#   - 실패 안내 한 쌍(원인 한 줄 + 다음 행동 한 줄)
#   - 실행 전 점검, 겹쳐 실행 막기

KIT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
KIT_MODE_FILE="$KIT_DIR/.kit-mode"
KIT_VENV="$KIT_DIR/.venv"
KIT_PIP_LOCK="$KIT_DIR/requirements-lock.txt"
KIT_PYTHON_SERIES="3.14"
KIT_UV_MIN="0.12"
# 대안 경로에서 쓸 파이썬 실행 파일. 이름이 다르면 KIT_PYTHON 으로 알려 주세요.
KIT_PYTHON="${KIT_PYTHON:-python$KIT_PYTHON_SERIES}"

# 실패 한 쌍 — 원인 한 줄, 다음 행동 한 줄. 둘 다 화면(표준 오류)으로 나갑니다.
kit_fail() { # $1=머리말 앞말  $2=원인  $3=다음 행동
  echo "$1 실패: $2" >&2
  echo "  다음: $3" >&2
}

kit_note() { # 판정에 넣지 않는 알림
  echo "알림: $1" >&2
}

# ── 호스트 셸 점검 ──────────────────────────────────────────────
# Windows에서는 리눅스 배포판(WSL2) 안에서만 씁니다. 호스트 셸에서 부르면
# 여기서 멈춥니다.
kit_host_shell_check() { # $1=머리말 앞말  $2=종료 코드
  case "$(uname -s)" in
    MINGW* | MSYS* | CYGWIN*)
      kit_fail "$1" \
        "윈도우 호스트 셸에서 실행되었습니다 — 이 코스의 파이썬과 도구는 WSL2 배포판 안에 설치합니다." \
        "0장의 윈도우 안내 절을 따라 WSL2 배포판(우분투) 셸을 연 뒤 그 안에서 다시 실행하세요."
      exit "$2"
      ;;
  esac
}

# ── 구축 경로 기억 ──────────────────────────────────────────────
# 차례: 환경 변수 KIT_MODE → 파일 .kit-mode → uv 명령이 있으면 uv, 없으면 venv.
kit_resolve_mode() {
  if [ -n "${KIT_MODE:-}" ]; then
    KIT_MODE_SOURCE="환경 변수"
  elif [ -f "$KIT_MODE_FILE" ]; then
    KIT_MODE=$(head -1 "$KIT_MODE_FILE" | tr -d ' \t\r\n')
    KIT_MODE_SOURCE="$KIT_MODE_FILE"
  elif command -v uv >/dev/null 2>&1; then
    KIT_MODE=uv
    KIT_MODE_SOURCE="기본값"
  else
    KIT_MODE=venv
    KIT_MODE_SOURCE="기본값"
  fi
  case "$KIT_MODE" in
    uv | venv) ;;
    *)
      echo "오류: 구축 경로를 적어 둔 파일의 내용이 uv 도 venv 도 아닙니다 (읽은 값: '$KIT_MODE')." >&2
      echo "  다음: rm $KIT_MODE_FILE 로 그 파일을 지운 뒤 ./setup.sh 를 다시 실행하세요." >&2
      exit 2
      ;;
  esac
}

kit_remember_mode() { # 구축에 성공한 경로를 적어 둡니다.
  printf '%s\n' "$1" > "$KIT_MODE_FILE" 2>/dev/null ||
    kit_note "구축 경로를 $KIT_MODE_FILE 에 적지 못했습니다. 다음부터는 KIT_MODE=$1 을 앞에 붙여 주세요."
}

# ── 파이썬 부르기 ───────────────────────────────────────────────
# 기본 경로는 uv 가 프로젝트 환경을 찾아 줍니다. 대안 경로는 .venv 안의
# 파이썬을 곧바로 부릅니다. 어느 쪽이든 같은 환경을 가리킵니다.
#
# kit 이 부르는 파이썬은 «여러분 컴퓨터의 개인 설정을 읽지 않습니다». 홈에 둔
# 시작 파일이나 PYTHONPATH 같은 값이 화면에 줄을 보태면, 검사가 여러분의 잘못이
# 아닌 일로 실패하기 때문입니다. 글자는 언제나 UTF-8로 주고받습니다 — 그래야
# 어느 컴퓨터에서나 한글이 같은 모양으로 나옵니다.
#
# PYTHONHASHSEED 도 못 박습니다. 이것을 두지 않으면 집합(set)을 훑는 차례가
# 실행할 때마다 달라져서, 틀린 곳이 없는데도 맞춰 보기가 실패합니다.
KIT_CLEAN_ENV="env -u PYTHONPATH -u PYTHONHOME -u PYTHONSTARTUP -u PYTHONWARNINGS PYTHONUTF8=1 PYTHONNOUSERSITE=1 PYTHONHASHSEED=0"

kit_py() {
  if [ "$KIT_MODE" = uv ]; then
    (cd "$KIT_DIR" && $KIT_CLEAN_ENV uv run --no-sync python "$@")
  else
    (cd "$KIT_DIR" && $KIT_CLEAN_ENV "$KIT_VENV/bin/python" "$@")
  fi
}

# 개인 설정을 그대로 둔 채 부릅니다 — 여러분이 터미널에서 직접 실행할 때와 같은
# 조건을 재어 볼 때만 씁니다 (환경 확인의 글자 인코딩 판정).
kit_py_plain() {
  if [ "$KIT_MODE" = uv ]; then
    (cd "$KIT_DIR" && uv run --no-sync python "$@")
  else
    (cd "$KIT_DIR" && "$KIT_VENV/bin/python" "$@")
  fi
}

kit_tool() { # $1=도구 이름, 나머지는 인자
  local tool="$1"
  shift
  if [ "$KIT_MODE" = uv ]; then
    (cd "$KIT_DIR" && $KIT_CLEAN_ENV uv run --no-sync "$tool" "$@")
  else
    (cd "$KIT_DIR" && $KIT_CLEAN_ENV "$KIT_VENV/bin/$tool" "$@")
  fi
}

# uv 판이 하한 이상인지 봅니다 (0.12 이상).
kit_uv_ok() {
  local v major minor
  v=$(uv --version 2>/dev/null | awk '/^uv /{print $2; exit}')
  [ -n "$v" ] || return 1
  major=${v%%.*}
  minor=${v#*.}
  minor=${minor%%.*}
  [ "$major" -gt 0 ] && return 0
  [ "$minor" -ge 12 ]
}

# ── 실행 전 점검 ────────────────────────────────────────────────
# 프로젝트 환경이 아직 없으면 스크립트마다 다른 화면을 내는 대신 여기서
# 한 번에 멈춥니다. 종료 코드는 부르는 쪽이 정합니다.
kit_runtime_check() { # $1=머리말 앞말  $2=종료 코드
  kit_host_shell_check "$1" "$2"
  if [ "$KIT_MODE" = uv ]; then
    if ! command -v uv >/dev/null 2>&1; then
      kit_fail "$1" \
        "uv 명령을 찾을 수 없습니다." \
        "0장의 파이썬 설치 절을 따라 uv 를 설치하세요. uv 를 쓰실 수 없는 환경이면 같은 장의 대안 경로 절을 보시고 KIT_MODE=venv ./setup.sh 를 한 번 실행하세요."
      exit "$2"
    fi
    if ! kit_uv_ok; then
      kit_fail "$1" \
        "uv 판이 이 코스가 요구하는 $KIT_UV_MIN 보다 낮습니다 (지금: $(uv --version 2>/dev/null | awk '/^uv /{print; exit}'))." \
        "uv self update 또는 brew upgrade uv 로 올린 뒤 ./setup.sh 를 다시 실행하세요."
      exit "$2"
    fi
  else
    if [ ! -x "$KIT_VENV/bin/python" ]; then
      kit_fail "$1" \
        "대안 경로의 프로젝트 환경($KIT_VENV)이 없습니다." \
        "KIT_MODE=venv ./setup.sh 를 한 번 실행해 프로젝트 환경을 만드세요."
      exit "$2"
    fi
  fi
  if [ ! -d "$KIT_VENV" ]; then
    kit_fail "$1" \
      "프로젝트 환경($KIT_VENV)이 아직 없습니다." \
      "./setup.sh 를 먼저 실행하세요."
    exit "$2"
  fi
}

# ── 겹쳐 실행 막기 ──────────────────────────────────────────────
# 같은 자료를 되돌리고 다시 읽는 일이 겹치면 결과가 실행할 때마다 달라집니다.
# 기다리지 않고 거절합니다 (종료 코드 2).
KIT_LOCK_DIR=""
kit_lock_acquire() { # $1=머리말 앞말
  [ -z "${KIT_LOCK_OWNED:-}" ] || return 0
  local key
  key=$(printf '%s' "$KIT_DIR" | cksum | awk '{print $1}')
  KIT_LOCK_DIR="/tmp/learning-loop-kit-python-fundamentals-$key.lock"
  if ! mkdir "$KIT_LOCK_DIR" 2>/dev/null; then
    local owner
    owner=$(cat "$KIT_LOCK_DIR/pid" 2>/dev/null || echo "?")
    if ! kill -0 "$owner" 2>/dev/null; then
      kit_note "끝난 실행이 남긴 표시를 걷어냈습니다 ($KIT_LOCK_DIR)."
      rm -rf "$KIT_LOCK_DIR"
      mkdir "$KIT_LOCK_DIR" 2>/dev/null || true
    else
      kit_fail "$1" \
        "같은 실습 자료를 쓰는 다른 실행이 이미 돌고 있습니다 (프로세스 $owner)." \
        "그 실행이 끝난 뒤 다시 실행하세요. 끝났는데도 같은 말이 나오면 rm -rf $KIT_LOCK_DIR 로 지운 뒤 다시 실행하세요."
      exit 2
    fi
  fi
  printf '%s\n' "$$" > "$KIT_LOCK_DIR/pid"
  KIT_LOCK_OWNED=1
  export KIT_LOCK_OWNED
  trap 'kit_lock_release' EXIT INT TERM
}

kit_lock_release() {
  [ -n "$KIT_LOCK_DIR" ] || return 0
  rm -rf "$KIT_LOCK_DIR"
  KIT_LOCK_DIR=""
}
