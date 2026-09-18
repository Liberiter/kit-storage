#!/usr/bin/env bash
# 실습 환경이 제대로 서 있는지 확인합니다.
#
#   ./check_env.sh
#
# 보는 것: 셸(윈도우면 WSL2 안인지) → 파이썬 판 → 도구 세 가지의 판이 잠금
# 파일과 같은지 → 자료 파일이 처음 상태인지.
# 어긋난 자리를 만나면 원인 한 줄과 다음에 할 일 한 줄을 내고 멈춥니다.
#
# 종료 코드: 0 통과 / 1 어긋난 자리 있음 / 2 실행 자체가 불가(셸·상태 파일).
if ! (eval ': <(:)') 2>/dev/null; then
  echo "오류: 이 스크립트는 프로세스 치환을 지원하는 bash 가 필요합니다 — 지금 셸에서는 꺼져 있어 확인을 시작하지 않았습니다." >&2
  echo "  다음: ./check_env.sh 또는 bash check_env.sh 로 실행하세요 (sh check_env.sh 는 POSIX 모드라 동작하지 않습니다)." >&2
  exit 2
fi

set -uo pipefail
cd "$(dirname "$0")" || exit 2
. ./kit_python.sh

LABEL="환경 확인"
kit_resolve_mode
kit_runtime_check "$LABEL" 1

# 1) 파이썬 판 — 이 코스는 3.14 판을 씁니다.
#
# 판을 읽을 때는 화면(표준 출력)에서 «찾는 줄 하나»만 집습니다. 줄 수나 차례로
# 집으면, 다른 무언가가 화면에 한 줄을 보태는 순간 엉뚱한 값을 읽고 「읽은 값」이
# 뒤죽박죽이 되어 원인을 가립니다. 이 파일에서 명령의 출력을 값으로 읽는 자리는
# 모두 같은 방식입니다.
if ! py_raw=$(kit_py --version 2>/dev/null); then
  kit_fail "$LABEL" \
    "프로젝트 환경의 파이썬을 실행하지 못했습니다." \
    "./setup.sh 를 다시 실행해 프로젝트 환경을 다시 만드세요."
  exit 1
fi
py_version=$(printf '%s\n' "$py_raw" | awk '/^Python /{print $2; exit}')
case "$py_version" in
  "$KIT_PYTHON_SERIES".*) ;;
  *)
    kit_fail "$LABEL" \
      "프로젝트 환경의 파이썬이 $KIT_PYTHON_SERIES 판이 아닙니다 (읽은 값: ${py_version:-없음})." \
      "기본 경로면 ./setup.sh 를 다시 실행해 프로젝트 환경을 다시 만드세요. 대안 경로면 0장의 대안 경로 절을 보세요."
    exit 1
    ;;
esac

# 2) 글자 인코딩 — 여러분이 터미널에서 직접 실행할 때 한글이 그대로 나오는지.
# kit 이 부르는 파이썬은 UTF-8로 못 박혀 있지만, 여러분이 손으로 실행할 때는
# 터미널 설정을 따릅니다. 교재의 화면과 어긋나는 가장 흔한 자리입니다.
enc=$(kit_py_plain -c 'import sys; print("kit-encoding=" + sys.stdout.encoding)' \
  2>/dev/null | awk -F= '/^kit-encoding=/{print $2; exit}')
case "$(printf '%s' "$enc" | tr 'A-Z' 'a-z' | tr -d '_-')" in
  utf8) ;;
  *)
    kit_fail "$LABEL" \
      "터미널이 주고받는 글자 인코딩이 UTF-8이 아닙니다 (읽은 값: ${enc:-없음}) — 한글이 깨져 보입니다." \
      "터미널이나 셸 설정에서 언어·문자 인코딩을 UTF-8로 맞춘 뒤(예: LANG=ko_KR.UTF-8) 다시 실행하세요."
    exit 1
    ;;
esac

# 3) 도구 판 — 잠금 파일에 적힌 값과 같아야 합니다.
lock_version() {
  awk -v pkg="$1" '
    $1 == "name" { gsub(/"/, "", $3); found = $3 }
    $1 == "version" && found == pkg { gsub(/"/, "", $3); print $3; exit }
  ' uv.lock
}

tools_shown=""
for tool in pytest ruff mypy; do
  want=$(lock_version "$tool")
  if [ -z "$want" ]; then
    kit_fail "$LABEL" \
      "잠금 파일(uv.lock)에서 $tool 의 판을 읽지 못했습니다." \
      "0장의 kit 받기 절을 따라 실습 폴더를 다시 받으세요."
    exit 1
  fi
  if ! got_raw=$(kit_tool "$tool" --version 2>/dev/null); then
    kit_fail "$LABEL" \
      "$tool 을 실행하지 못했습니다 (있어야 할 판 $want)." \
      "./setup.sh 를 다시 실행해 프로젝트 환경을 잠금 파일대로 맞추세요."
    exit 1
  fi
  got=$(printf '%s\n' "$got_raw" | awk -v t="$tool" '$1 == t {print $2; exit}')
  if [ "$got" != "$want" ]; then
    kit_fail "$LABEL" \
      "$tool 의 판이 잠금 파일과 다릅니다 (있어야 할 판 $want, 지금 ${got:-없음})." \
      "./setup.sh 를 다시 실행해 프로젝트 환경을 잠금 파일대로 맞추세요."
    exit 1
  fi
  tools_shown="$tools_shown $tool $got ·"
done
tools_shown=${tools_shown% ·}

# 4) 자료 파일 — 처음 상태 그대로인지.
if ! world_out=$(kit_py world_check.py 2>&1); then
  kit_fail "$LABEL" \
    "자료 파일이 처음 상태와 다릅니다." \
    "./reset.sh 로 되돌린 뒤 다시 확인하세요. 그래도 같은 말이 나오면 ./setup.sh 를 다시 실행하세요."
  printf '%s\n' "$world_out" | sed 's/^/    /' >&2
  exit 1
fi

echo "환경 확인 통과: 파이썬 $py_version,$tools_shown, 자료 파일 이상 없음 (경로: $KIT_MODE)"
