#!/usr/bin/env bash
# 실습 환경을 처음 만드는 스크립트입니다.
#
#   ./setup.sh                  기본 경로 — uv 가 파이썬과 도구를 준비합니다
#   KIT_MODE=venv ./setup.sh    대안 경로 — 시스템에 설치된 파이썬 + venv + pip
#
# 하는 일: 파이썬과 도구 준비 → 작업 자리 만들기 → 자료 파일 만들기 →
# 답안 파일 마련 → 환경 확인. 마지막에 어느 경로로 구축했는지 적어 둡니다.
#
# 윈도우에서는 WSL2 배포판(우분투) 셸 안에서 실행합니다. 윈도우 호스트에는
# 파이썬을 설치하지 않습니다.
#
# 이 스크립트는 bash 의 기능을 씁니다. 그것이 꺼진 셸에서 부르면 아무것도
# 만들지 않고 거절합니다 — 절반만 만들어 둔 환경이 가장 고치기 어렵습니다.
if ! (eval ': <(:)') 2>/dev/null; then
  echo "오류: 이 스크립트는 프로세스 치환을 지원하는 bash 가 필요합니다 — 지금 셸에서는 꺼져 있어 아무것도 만들지 않았습니다." >&2
  echo "  다음: ./setup.sh 또는 bash setup.sh 로 실행하세요 (sh setup.sh 는 POSIX 모드라 동작하지 않습니다)." >&2
  exit 2
fi

set -uo pipefail
cd "$(dirname "$0")" || exit 2
. ./kit_python.sh

LABEL="구축"
kit_resolve_mode
kit_host_shell_check "$LABEL" 1
kit_lock_acquire "$LABEL"

run_or_fail() { # $1=원인  $2=다음 행동  나머지=실행할 명령
  local why="$1" next="$2"
  shift 2
  local out
  if ! out=$("$@" 2>&1); then
    kit_fail "$LABEL" "$why" "$next"
    printf '%s\n' "$out" | sed 's/^/    /' >&2
    exit 1
  fi
}

if [ "$KIT_MODE" = uv ]; then
  if ! command -v uv >/dev/null 2>&1; then
    kit_fail "$LABEL" \
      "uv 명령을 찾을 수 없습니다." \
      "0장의 파이썬 설치 절을 따라 uv 를 설치하세요. uv 를 쓰실 수 없는 환경이면 같은 장의 대안 경로 절을 보시고 KIT_MODE=venv ./setup.sh 로 실행하세요."
    exit 1
  fi
  if ! kit_uv_ok; then
    kit_fail "$LABEL" \
      "uv 판이 이 코스가 요구하는 $KIT_UV_MIN 보다 낮습니다 (지금: $(uv --version 2>/dev/null | awk '/^uv /{print; exit}'))." \
      "uv self update 또는 brew upgrade uv 로 올린 뒤 다시 실행하세요."
    exit 1
  fi
  echo "파이썬 준비: CPython $KIT_PYTHON_SERIES 을 uv 가 맡습니다."
  run_or_fail "CPython $KIT_PYTHON_SERIES 을 준비하지 못했습니다." \
    "인터넷 연결을 확인한 뒤 다시 실행하세요. 회사 망 등으로 내려받을 수 없으면 0장의 대안 경로 절을 보세요." \
    uv python install "$KIT_PYTHON_SERIES"
  echo "프로젝트 환경 준비: .venv 에 pytest·ruff·mypy 를 잠금 파일대로 넣습니다."
  run_or_fail "프로젝트 환경을 만들지 못했습니다." \
    "인터넷 연결을 확인한 뒤 다시 실행하세요. 그래도 같은 말이 나오면 rm -rf .venv 로 지우고 다시 실행하세요." \
    uv sync --frozen
else
  echo "대안 경로(KIT_MODE=venv): 시스템에 설치된 $KIT_PYTHON 으로 프로젝트 환경을 만듭니다."
  if ! command -v "$KIT_PYTHON" >/dev/null 2>&1; then
    kit_fail "$LABEL" \
      "$KIT_PYTHON 명령을 찾을 수 없습니다." \
      "0장의 대안 경로 절을 따라 CPython $KIT_PYTHON_SERIES 을 설치하세요. 이름이 다르면 KIT_PYTHON=<실행 파일 이름> 을 앞에 붙여 실행하세요."
    exit 1
  fi
  # 판은 「Python 3.14.7」 꼴의 줄에서만 집습니다 — 여러분 컴퓨터의 개인 설정이
  # 시작할 때 화면에 줄을 보태도 엉뚱한 값을 읽지 않도록.
  found=$("$KIT_PYTHON" --version 2>/dev/null | awk '/^Python /{print $2; exit}')
  case "$found" in
    "$KIT_PYTHON_SERIES".*) ;;
    *)
      kit_fail "$LABEL" \
        "$KIT_PYTHON 의 판이 $found 입니다 — 이 코스는 $KIT_PYTHON_SERIES 판을 씁니다." \
        "0장의 대안 경로 절을 따라 $KIT_PYTHON_SERIES 을 설치한 뒤, 그 실행 파일 이름을 KIT_PYTHON=<이름> 으로 알려 주세요."
      exit 1
      ;;
  esac
  echo "파이썬 준비: Python $found ($(command -v "$KIT_PYTHON"))"
  if [ ! -x "$KIT_VENV/bin/python" ]; then
    run_or_fail "프로젝트 환경(.venv)을 만들지 못했습니다." \
      "쓰기 권한이 있는 자리인지 확인하고, rm -rf .venv 로 지운 뒤 다시 실행하세요." \
      "$KIT_PYTHON" -m venv "$KIT_VENV"
  fi
  if [ ! -f "$KIT_PIP_LOCK" ]; then
    kit_fail "$LABEL" \
      "대안 경로가 쓰는 잠금 파일($KIT_PIP_LOCK)이 없습니다." \
      "0장의 kit 받기 절을 따라 실습 폴더를 다시 받으세요."
    exit 1
  fi
  echo "프로젝트 환경 준비: .venv 에 pytest·ruff·mypy 를 잠금 파일대로 넣습니다."
  run_or_fail "도구를 넣지 못했습니다." \
    "인터넷 연결을 확인한 뒤 다시 실행하세요. 그래도 같은 말이 나오면 rm -rf .venv 로 지우고 다시 실행하세요." \
    "$KIT_VENV/bin/python" -m pip install --quiet --disable-pip-version-check \
    --no-deps -r "$KIT_PIP_LOCK"
fi

mkdir -p work out

made=$(kit_py make_world.py 2>&1)
if [ $? -ne 0 ]; then
  kit_fail "$LABEL" \
    "자료 파일을 만들지 못했습니다 (아래 줄이 무엇이 없거나 막혔는지 말해 줍니다)." \
    "실습 폴더가 온전한지 보세요 — 0장의 kit 받기 절을 따라 다시 받은 뒤 ./setup.sh 를 실행하시면 됩니다."
  printf '%s\n' "$made" | sed 's/^/    /' >&2
  exit 1
fi
echo "자료 파일 준비: $(printf '%s\n' "$made" | tail -1)"

# 마무리 문제의 답을 적는 파일입니다. 없으면 만들어 드리고, 이미 있으면
# 손대지 않습니다 — 적어 두신 내용이 사라지면 안 되기 때문입니다.
made_count=0
kept_count=0
for src in exit/templates/*; do
  [ -f "$src" ] || continue
  dst="exit/$(basename "$src")"
  if [ -e "$dst" ]; then
    kept_count=$((kept_count + 1))
  else
    cp "$src" "$dst"
    made_count=$((made_count + 1))
  fi
done
if [ "$made_count" -gt 0 ]; then
  echo "답안 파일 생성: exit/ 에 $made_count 개를 새로 만들었습니다."
fi
if [ "$kept_count" -gt 0 ]; then
  echo "답안 파일 유지: exit/ 에 이미 있는 $kept_count 개는 그대로 두었습니다."
fi

kit_remember_mode "$KIT_MODE"

if ! ./check_env.sh; then
  kit_fail "$LABEL" \
    "환경 확인을 통과하지 못했습니다 (위 줄이 무엇이 어긋났는지 말해 줍니다)." \
    "위 안내를 따른 뒤 ./setup.sh 를 다시 실행하세요."
  exit 1
fi

echo "구축 완료 (경로: $KIT_MODE)"
echo "다음 단계: ./entry_check.sh 를 실행해 통과 화면을 확인하세요."
