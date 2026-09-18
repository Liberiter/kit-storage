#!/usr/bin/env bash
# 입장 점검 — 이 코스를 시작할 준비가 되었는지 확인합니다.
#
#   ./entry_check.sh
#
# 이 코스의 입장 점검에는 풀어야 할 문제가 없습니다. 파이썬을 처음 배우는
# 분을 전제한 코스이므로, 확인하는 것은 아는 것이 아니라 **환경이 서 있는지**
# 입니다. 두 단계로 봅니다.
#   1단계 — 환경 확인 (./check_env.sh 와 같은 검사)
#   2단계 — 예제 실행 확인 (실습 자료 위에서 예제가 예상대로 도는지)
#
# 종료 코드: 0 통과 / 1 미통과 / 2 실행 자체가 불가(셸·상태 파일·겹쳐 실행).
if ! (eval ': <(:)') 2>/dev/null; then
  echo "오류: 이 스크립트는 프로세스 치환을 지원하는 bash 가 필요합니다 — 지금 셸에서는 꺼져 있어 점검을 시작하지 않았습니다." >&2
  echo "  다음: ./entry_check.sh 또는 bash entry_check.sh 로 실행하세요 (sh entry_check.sh 는 POSIX 모드라 동작하지 않습니다)." >&2
  exit 2
fi

set -uo pipefail
cd "$(dirname "$0")" || exit 2
. ./kit_python.sh

LABEL="entry check"
if [ $# -gt 0 ]; then
  echo "사용법: ./entry_check.sh (붙일 인자가 없습니다)" >&2
  exit 2
fi

kit_resolve_mode
kit_runtime_check "$LABEL" 1
kit_lock_acquire "$LABEL"

STAGING=".entry-staging"

echo "== 1단계: 환경 확인"
if ! ./check_env.sh; then
  echo "입장 점검 미통과: 환경 확인에서 막혔습니다 (위 줄이 무엇이 어긋났는지 말해 줍니다)." >&2
  echo "  다음: 위 안내 한 줄을 따른 뒤 ./entry_check.sh 를 다시 실행하세요." >&2
  exit 1
fi

echo "== 2단계: 예제 실행 확인"
rm -rf "$STAGING"
mkdir -p "$STAGING"
copied=0
for src in cases/[0-9][0-9]-*; do
  [ -e "$src" ] || continue
  cp "$src" "$STAGING/" || {
    echo "오류: 확인용 예제를 옮기지 못했습니다 ($src)." >&2
    echo "  다음: 이 폴더에 쓰기 권한이 있는지 확인한 뒤 다시 실행하세요." >&2
    rm -rf "$STAGING"
    exit 2
  }
  copied=$((copied + 1))
done
if [ "$copied" -eq 0 ]; then
  echo "입장 점검 미통과: 확인에 쓸 예제 파일이 실습 폴더에 없습니다." >&2
  echo "  다음: 0장의 kit 받기 절을 따라 실습 폴더를 다시 받은 뒤 ./setup.sh 를 실행하세요." >&2
  rm -rf "$STAGING"
  exit 1
fi

if ! ./verify.sh "$STAGING"; then
  echo "입장 점검 미통과: 예제 실행 결과가 기대와 다릅니다." >&2
  echo "  다음: ./setup.sh 를 다시 실행해 보시고, 그래도 같은 말이 나오면 0장의 실패했을 때를 다루는 절을 보세요." >&2
  rm -rf "$STAGING"
  exit 1
fi
rm -rf "$STAGING"

echo "입장 점검 통과: 환경과 예제 실행을 모두 확인했습니다 (경로: $KIT_MODE)."
