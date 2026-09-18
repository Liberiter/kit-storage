#!/usr/bin/env bash
# 실습 자료를 처음 상태로 되돌립니다.
#
#   ./reset.sh
#
# 되돌리는 것: data/(관측 자료), examples/(예제 프로그램), broken/(일부러
# 고장 내 둔 파일). 그리고 out/(결과를 쓰는 자리)를 비웁니다.
# 건드리지 않는 것: work/ 에 여러분이 만든 파일, exit/ 에 적어 두신 답안,
# 프로젝트 환경(.venv).
#
# 종료 코드: 0 성공 / 1 되돌리기 실패 / 2 실행 자체가 불가.
if ! (eval ': <(:)') 2>/dev/null; then
  echo "오류: 이 스크립트는 프로세스 치환을 지원하는 bash 가 필요합니다 — 지금 셸에서는 꺼져 있어 아무것도 되돌리지 않았습니다." >&2
  echo "  다음: ./reset.sh 또는 bash reset.sh 로 실행하세요 (sh reset.sh 는 POSIX 모드라 동작하지 않습니다)." >&2
  exit 2
fi

set -uo pipefail
cd "$(dirname "$0")" || exit 2
. ./kit_python.sh

LABEL="reset"
kit_resolve_mode
kit_runtime_check "$LABEL" 2
kit_lock_acquire "$LABEL"

mkdir -p work out

if ! made=$(kit_py make_world.py 2>&1); then
  kit_fail "$LABEL" \
    "자료 파일을 다시 만들지 못했습니다 (아래 줄이 무엇이 없거나 막혔는지 말해 줍니다)." \
    "먼저 다른 ./verify.sh·./reset.sh·./entry_check.sh 가 돌고 있지 않은지 확인하세요. 아니라면 실습 폴더가 온전한지 보고(0장의 kit 받기 절) ./setup.sh 를 다시 실행하세요."
  printf '%s\n' "$made" | sed 's/^/    /' >&2
  exit 1
fi

# out/ 을 비웁니다. 자리 표시 파일 하나는 남겨 폴더가 사라지지 않게 합니다.
# 지우는 명령이 「했다」고 답해도 실제로 남았는지를 다시 봅니다 — 권한이 없으면
# 한 건씩 건너뛰면서도 성공으로 끝나는 수가 있습니다.
sweep_err=$(find out -mindepth 1 ! -name .gitkeep -delete 2>&1)
sweep_left=$(find out -mindepth 1 ! -name .gitkeep 2>/dev/null | head -3 | tr '\n' ' ')
if [ -n "$sweep_left" ]; then
  kit_fail "$LABEL" \
    "out/ 을 다 비우지 못했습니다 (남은 것: $sweep_left)." \
    "out/ 과 그 안의 파일에 쓰기 권한이 있는지 보시고, 다른 프로그램이 그 파일을 열고 있지 않은지 확인한 뒤 다시 실행하세요."
  [ -n "$sweep_err" ] && printf '%s\n' "$sweep_err" | sed 's/^/    /' >&2
  exit 1
fi

echo "되돌리기 완료: $(printf '%s\n' "$made" | tail -1), out/ 비움"
