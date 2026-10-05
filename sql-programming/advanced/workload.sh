#!/usr/bin/env bash
# 워크로드 — 책숲 서비스가 하루에 보내는 질의를 줄여 흉내 낸 묶음을 world 위에서 돌린다 (1장).
# 빠른 질의와 느린 질의가 섞여 있다. 무엇이 느린지는 이 스크립트가 알려 주지 않는다 — 돌린 뒤
# pg_stat_statements 로 직접 들여다보는 것이 실습이다.
#
# 사용법:
#   ./workload.sh          # 묶음을 한 번 돌린다
#   ./workload.sh 3        # 세 번 돌린다 (1~10)
#
# 시작할 때 이 world 데이터베이스의 pg_stat_statements 기록을 비운다 — 이 데이터베이스의 것만 비우고 다른
# 데이터베이스의 기록은 건드리지 않는다. 질의는 workload/ 의 파일들이고 world 를 바꾸지 않는다(읽기만).
# 같은 world 를 쓰는 다른 실행(./verify.sh 등)과 겹치지 않게 잠금을 잡는다.
#
# 종료 코드: 0 = 다 돌렸다 / 2 = 실행 오류
# 이 스크립트는 bash 로 돈다 — bash 가 아닌 셸(dash 등)로 부르면 셸 자신의 오류로 끝나 kit 의 안내가 나올
# 자리가 없으므로, 먼저 확인하고 거절한다. (macOS 의 sh 는 POSIX 모드의 bash 라 그대로 돈다.)
if [ -z "${BASH_VERSION:-}" ]; then
  echo "workload 실패: 이 스크립트는 bash가 필요합니다 — 지금 셸은 bash가 아니라 워크로드를 시작하지 않았습니다." >&2
  echo "  다음: ./workload.sh 또는 bash workload.sh 로 실행하세요." >&2
  exit 2
fi
set -uo pipefail
cd "$(dirname "$0")"
[ -r ./kit_psql.sh ] || {
  echo "workload 실패: kit 파일 kit_psql.sh 을(를) 읽을 수 없습니다." >&2
  echo "  다음: 파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)." >&2
  exit 2; }
. ./kit_psql.sh

DB="$KIT_DB"
fail2() {
  echo "workload 실패: $1" >&2
  [ "${2:-}" = "" ] || echo "  다음: $2" >&2
  exit 2
}

ROUNDS="${1:-1}"
case "$ROUNDS" in ''|*[!0-9]*) echo "사용법: ./workload.sh [돌릴 횟수 1~10]" >&2; exit 2 ;; esac
[ "$ROUNDS" -ge 1 ] && [ "$ROUNDS" -le 10 ] || { echo "사용법: ./workload.sh [돌릴 횟수 1~10]" >&2; exit 2; }
[ $# -le 1 ] || { echo "사용법: ./workload.sh [돌릴 횟수 1~10]" >&2; exit 2; }

files=""
for f in workload/*.sql; do [ -r "$f" ] && files="$files $f"; done
[ -n "$files" ] || fail2 "kit 파일 workload/*.sql 을(를) 읽을 수 없습니다" "파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)"

kit_runtime_check "workload" 2
kit_connect_check "workload" 2
kit_lock_acquire

out=$(kit_psql -d "$DB" -X -q -v ON_ERROR_STOP=1 \
        -c "SELECT pg_stat_statements_reset(0, (SELECT oid FROM pg_database WHERE datname = current_database()), 0)" 2>&1) \
  || { printf '%s\n' "$out" | sed 's/^/  /' >&2
       fail2 "pg_stat_statements 기록을 비우지 못했습니다" "./check_env.sh 로 관찰 도구가 준비되었는지 확인하세요"; }

echo "워크로드: workload/ 의 질의 묶음 $(printf '%s\n' $files | wc -l | tr -d ' ')개를 ${ROUNDS}번 돌립니다 (이 데이터베이스의 pg_stat_statements 기록은 방금 비웠습니다)."
t0=$(date +%s)
r=1
while [ $r -le "$ROUNDS" ]; do
  for f in $files; do
    if ! out=$(kit_psql -d "$DB" -X -q -v ON_ERROR_STOP=1 < "$f" 2>&1 >/dev/null); then
      printf '%s\n' "$out" | sed 's/^/  /' >&2
      fail2 "워크로드 파일 $f 을(를) 실행하지 못했습니다" "./reset.sh 로 world 를 초기 상태로 되돌린 뒤 다시 실행하세요 — 테이블이나 열을 바꾼 채로는 워크로드가 돌지 않을 수 있습니다"
    fi
  done
  r=$((r + 1))
done
t1=$(date +%s)
echo "워크로드 완료: 약 $((t1 - t0))초. 무엇이 시간을 썼는지는 pg_stat_statements 뷰로 들여다보세요 — 예:"
echo "  SELECT calls, round(total_exec_time) AS total_ms, round(mean_exec_time::numeric, 1) AS mean_ms, left(query, 60) AS query"
echo "    FROM pg_stat_statements WHERE dbid = (SELECT oid FROM pg_database WHERE datname = current_database())"
echo "   ORDER BY total_exec_time DESC LIMIT 10;"
