#!/usr/bin/env bash
# 검증 러너 — 예제 프로그램을 실습 자료 위에서 실행하고 기대 출력과 맞춰 봅니다.
# 이 코스를 만들고 검토하는 쪽이 쓰는 도구입니다.
#
#   ./verify.sh [케이스 디렉토리]            실행·대조 (기본: ./cases)
#   ./verify.sh --update [케이스 디렉토리]   기대 출력(.expected) 다시 만들기
#
# 케이스 규약:
#   <이름>.py        실행할 파일. 첫 줄은 이 케이스가 무엇을 받치는지 적은 # 주석.
#   <이름>.expected  기대 출력 (화면에 나오는 줄 + 마지막 줄 "[exit N]").
#   <이름>.stdin     (있으면) 표준 입력으로 흘려 넣을 내용.
#   첫 줄 주석에 "runner: reset" 이 있으면 실행 앞뒤로 실습 자료를 되돌립니다.
#
# 실행 자리는 언제나 이 폴더입니다 — 케이스 안의 data/… 같은 상대 경로가 늘
# 같은 자리를 가리키도록. 화면에 이 폴더의 전체 경로가 찍히면(오류 화면의 파일
# 경로 등) 이 폴더를 뿌리로 한 상대 경로로 바꾸어 견줍니다. 전체 경로는 컴퓨터
# 마다 다르기 때문입니다.
#
# 겹쳐 실행 막기: 같은 실습 자료를 쓰는 다른 실행이 돌고 있으면 기다리지 않고
# 종료 코드 2로 거절합니다.
#
# 종료 코드: 0 전량 통과 / 1 실패 케이스 있음 / 2 실행 오류.
#
# 이 스크립트는 프로세스 치환(bash 기능)을 씁니다. 그것이 꺼진 셸에서는 케이스를
# 한 건도 실행하지 않고 거절합니다 — 0건 실행은 통과도 전량 실패도 아니므로
# 종료 코드 2로 가릅니다.
if ! (eval ': <(:)') 2>/dev/null; then
  echo "오류: 이 스크립트는 프로세스 치환을 지원하는 bash 가 필요합니다 — 지금 셸에서는 꺼져 있어 케이스를 한 건도 실행하지 않았습니다." >&2
  echo "  다음: ./verify.sh 또는 bash verify.sh 로 실행하세요 (sh verify.sh 는 POSIX 모드라 동작하지 않습니다)." >&2
  exit 2
fi

set -uo pipefail
cd "$(dirname "$0")" || exit 2
. ./kit_python.sh

LABEL="verify"
kit_resolve_mode

MODE=run
if [ "${1:-}" = "--update" ]; then
  MODE=update
  shift
fi
DIR="${1:-cases}"
if [ ! -d "$DIR" ]; then
  echo "오류: 케이스 디렉토리가 없습니다: $DIR" >&2
  echo "  다음: ./verify.sh <있는 디렉토리> 로 다시 실행하세요 (적지 않으면 ./cases 를 봅니다)." >&2
  exit 2
fi

kit_runtime_check "$LABEL" 2
kit_lock_acquire "$LABEL"

shopt -s nullglob
files=("$DIR"/*.py)
if [ ${#files[@]} -eq 0 ]; then
  echo "오류: $DIR 에 .py 케이스가 없습니다." >&2
  echo "  다음: 케이스 파일(<이름>.py + <이름>.expected)을 둔 디렉토리를 적어 주세요." >&2
  exit 2
fi

KIT_PREFIX="$KIT_DIR/"

run_case() { # $1=케이스 파일 → 화면 출력 + "[exit N]"
  local src="$1" feed="${1%.py}.stdin" out rc
  if [ -f "$feed" ]; then
    out=$(kit_py "$src" < "$feed" 2>&1)
    rc=$?
  else
    out=$(kit_py "$src" < /dev/null 2>&1)
    rc=$?
  fi
  out=${out//"$KIT_PREFIX"/}
  printf '%s\n[exit %d]\n' "$out" "$rc"
}

pass=0
failed=0
failed_names=()
for src in "${files[@]}"; do
  name=$(basename "$src" .py)
  expected="${src%.py}.expected"
  is_reset=0
  head -1 "$src" | grep -q 'runner: reset' && is_reset=1

  if [ $is_reset = 1 ]; then
    if ! ./reset.sh > /dev/null; then
      echo "오류: 케이스 $name 을 실행하기 전에 실습 자료를 되돌리지 못했습니다 (위 안내 참고)." >&2
      echo "  다음: ./reset.sh 를 직접 실행해 원인을 확인한 뒤 다시 돌리세요." >&2
      exit 2
    fi
  fi

  actual=$(run_case "$src")

  if [ $is_reset = 1 ]; then
    if ! ./reset.sh > /dev/null; then
      echo "오류: 케이스 $name 을 실행한 뒤 실습 자료를 되돌리지 못했습니다 (위 안내 참고)." >&2
      echo "  다음: ./reset.sh 를 직접 실행해 원인을 확인한 뒤 다시 돌리세요." >&2
      exit 2
    fi
  fi

  if [ "$MODE" = update ]; then
    printf '%s' "$actual" > "$expected"
    echo "갱신: $name"
    continue
  fi

  if [ ! -f "$expected" ]; then
    echo "FAIL $name — 기대 출력 파일이 없습니다 ($expected). --update 로 만드세요."
    failed=$((failed + 1))
    failed_names+=("$name")
    continue
  fi
  if diff_out=$(diff -u "$expected" <(printf '%s' "$actual")); then
    echo "PASS $name"
    pass=$((pass + 1))
  else
    echo "FAIL $name"
    printf '%s\n' "$diff_out" | sed 's/^/    /'
    failed=$((failed + 1))
    failed_names+=("$name")
  fi
done

if [ "$MODE" = update ]; then
  exit 0
fi

echo "----"
echo "결과: PASS $pass / FAIL $failed"
if [ $failed -gt 0 ]; then
  echo "실패 케이스: ${failed_names[*]}"
  echo "  다음: 먼저 다른 ./verify.sh·./reset.sh·./entry_check.sh 가 같은 실습 자료를 쓰고 있지 않았는지 확인하세요(겹치면 결과가 흔들립니다). 아니라면 위 차이를 본문·케이스와 견주고, 자료가 의심되면 ./reset.sh 뒤 다시 실행하세요."
  exit 1
fi
