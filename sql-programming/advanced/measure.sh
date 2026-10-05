#!/usr/bin/env bash
# 측정 — 질의 하나를 EXPLAIN (ANALYZE, BUFFERS) 로 여러 번 실행해 계획의 모양과 실행 시간을 낸다.
# 질의를 고치거나 인덱스를 만든 «전과 후»를 같은 방법으로 재는 도구다 (5·9장, 마지막 평가 장의 개선 문항).
#
# 사용법:
#   ./measure.sh <질의 파일> [반복 횟수]                    # 기본 5회
#   ./measure.sh --compare <전 질의 파일> <후 질의 파일> [반복 횟수]
#
# 질의 파일에는 **문장 하나만** 둔다 (끝의 ; 와 -- 주석은 있어도 된다). SELECT 만이 아니라 INSERT·UPDATE·
# DELETE 도 잴 수 있고, 그때는 매번 트랜잭션 안에서 실행한 뒤 되돌린다(BEGIN … ROLLBACK) — world 의 데이터는
# 바뀌지 않는다. 다만 되돌린 변경도 테이블에 죽은 행 버전을 남기므로, 변경 문장을 잰 뒤에는 ./reset.sh 로
# 되돌린 다음 다른 실습으로 넘어간다. 인덱스를 만든 뒤를 재려면 CREATE INDEX 는 psql 에서 먼저 실행하고 이 도구로는 질의만 잰다.
#
# 화면:
#   계획      노드의 차례와 이름 — EXPLAIN 의 들여쓰기와 같은 모양으로, 비용·행 수 없이 노드만.
#             정렬·해시가 메모리를 넘어 디스크를 썼으면 그 표시가 붙는다.
#   1회째     처음 실행의 시간과 버퍼 — 공유 버퍼에 아직 없는 블록을 읽어 오는(read) 몫이 섞인다.
#   2회째부터 나머지 실행 시간의 중앙값.
# 시간은 실행할 때마다, 컴퓨터마다 달라진다 — 비교는 같은 컴퓨터에서 연달아 잰 값끼리 한다.
# 계획이 실행마다 달라지면 그 사실을 알린다.
#
# 종료 코드: 0 = 측정함 / 2 = 실행 오류 (파일·접속·질의 오류)
#
# 이 스크립트는 bash 전용 기능을 쓰므로, 그것이 꺼진 셸(sh measure.sh)에서는 시작하지 않고 거절한다.
if ! (eval ': <(:)') 2>/dev/null; then
  echo "오류: 이 스크립트는 bash가 필요합니다 — 지금 셸에서는 bash 기능(프로세스 치환 등)이 꺼져 있어 측정을 시작하지 않았습니다." >&2
  echo "  다음: ./measure.sh 또는 bash measure.sh 로 실행하세요 (sh measure.sh 는 POSIX 모드라 동작하지 않습니다)." >&2
  exit 2
fi

set -uo pipefail
CALLER="$PWD"
cd "$(dirname "$0")"
[ -r ./kit_psql.sh ] || {
  echo "measure 실패: kit 파일 kit_psql.sh 을(를) 읽을 수 없습니다." >&2
  echo "  다음: 파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)." >&2
  exit 2; }
. ./kit_psql.sh

DB="$KIT_DB"

usage() {
  echo "사용법: ./measure.sh <질의 파일> [반복 횟수]" >&2
  echo "        ./measure.sh --compare <전 질의 파일> <후 질의 파일> [반복 횟수]" >&2
  exit 2
}
fail2() {
  echo "measure 실패: $1" >&2
  [ "${2:-}" = "" ] || echo "  다음: $2" >&2
  exit 2
}

resolve() { # 부른 자리 기준 경로를 먼저 본다
  case "$1" in
    /*) printf '%s' "$1" ;;
    *) if [ -r "$CALLER/$1" ]; then printf '%s' "$CALLER/$1"; else printf '%s' "$1"; fi ;;
  esac
}

COMPARE=0
if [ "${1:-}" = "--compare" ]; then COMPARE=1; shift; fi
if [ $COMPARE = 1 ]; then
  [ $# -ge 2 ] && [ $# -le 3 ] || usage
  F1="$(resolve "$1")"; F2="$(resolve "$2")"; N="${3:-5}"
  N1="$1"; N2="$2"
else
  [ $# -ge 1 ] && [ $# -le 2 ] || usage
  F1="$(resolve "$1")"; F2=""; N="${2:-5}"
  N1="$1"
fi
case "$N" in ''|*[!0-9]*) usage ;; esac
[ "$N" -ge 2 ] && [ "$N" -le 50 ] || fail2 "반복 횟수 $N — 2~50 사이로 주세요" "예: ./measure.sh 질의.sql 5"
for f in "$F1" ${F2:+"$F2"}; do
  [ -r "$f" ] || fail2 "질의 파일을 읽을 수 없습니다: $f" "파일 경로를 확인하세요"
done

kit_runtime_check "measure" 2
kit_connect_check "measure" 2
kit_lock_acquire   # 재는 동안 다른 실행이 world 를 다시 만들지 않게

# 한 파일을 N번 잰다. psql 한 세션 안에서 실행마다 트랜잭션을 열어 EXPLAIN (ANALYZE, BUFFERS) 를 돌리고
# 되돌린다 — 절차는 measure.sql 에 있다. 화면에 낼 값은 「__RUN__ 실행ms 계획ms hit read 계획지문」 줄과
# 「__SHAPE__ 노드」 줄로 받는다.
[ -r measure.sql ] || fail2 "kit 파일 measure.sql 을(를) 읽을 수 없습니다" "파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)"
PROGRAM_HEAD="$(sed -n '1,/^-- @run$/p' measure.sql | sed '$d')"
PROGRAM_RUN="$(sed -n '/^-- @run$/,/^-- @tail$/p' measure.sql | sed -e '1d' -e '$d')"
PROGRAM_TAIL="$(sed -n '/^-- @tail$/,$p' measure.sql | sed '1d')"

RUN_OUT=""
measure_file() { # $1=파일 → RUN_OUT 에 psql 출력. 실패하면 rc 2 로 끝낸다.
  local q prog k
  q="$(cat "$1")"
  prog="$PROGRAM_HEAD"
  k=1
  while [ $k -le "$N" ]; do prog="$prog
$PROGRAM_RUN"; k=$((k + 1)); done
  prog="$prog
$PROGRAM_TAIL"
  if ! RUN_OUT=$(printf '%s\n' "$prog" | kit_psql_merged -d "$DB" -q -t -A -v ON_ERROR_STOP=1 --pset pager=off -v q="$q"); then
    printf '%s\n' "$RUN_OUT" | grep -v '^__' | sed 's/^/  /' >&2
    fail2 "질의를 실행하지 못했습니다: $2 (위 psql 메시지)" \
          "그 파일에 문장이 하나만 있는지, psql 에서 그대로 실행되는지 확인하세요 (여러 문장·psql 명령(\\로 시작하는 줄)은 잴 수 없습니다)"
  fi
}

# 실행 줄들에서 값을 뽑아 요약한다. 요약 값은 SUM_FIRST·SUM_MEDIAN 에 남긴다.
SUM_FIRST=""; SUM_MEDIAN=""
summarize() { # $1=이름
  local runs first rest shapes
  runs="$(printf '%s\n' "$RUN_OUT" | sed -n 's/^__RUN__ //p')"
  if [ "$(printf '%s\n' "$runs" | awk 'NF == 5 && $1 ~ /^[0-9.]+$/' | wc -l | tr -d ' ')" != "$N" ]; then
    printf '%s\n' "$RUN_OUT" | grep -v '^__' | sed 's/^/  /' >&2
    fail2 "측정 결과를 읽지 못했습니다: $1" "그 파일에 문장이 하나만 있는지, psql 에서 그대로 실행되는지 확인하세요"
  fi
  echo "측정: $1 (${N}회 실행 — 변경 문장은 매번 되돌렸습니다)"
  echo "계획:"
  printf '%s\n' "$RUN_OUT" | sed -n 's/^__SHAPE__ /  /p'
  shapes="$(printf '%s\n' "$runs" | awk '{ print $5 }' | sort -u | wc -l | tr -d ' ')"
  [ "$shapes" = 1 ] || echo "  (알림: 계획이 실행마다 달랐습니다 — 위는 마지막 실행의 계획입니다. 실행마다 다른 계획 ${shapes}가지)"
  first="$(printf '%s\n' "$runs" | head -1)"
  SUM_FIRST="$(printf '%s' "$first" | awk '{ print $1 }')"
  echo "1회째: 실행 $(printf '%s' "$first" | awk '{ printf "%.2f", $1 }') ms, 계획 $(printf '%s' "$first" | awk '{ printf "%.2f", $2 }') ms, 버퍼 hit=$(printf '%s' "$first" | awk '{ print $3 }') read=$(printf '%s' "$first" | awk '{ print $4 }')"
  rest="$(printf '%s\n' "$runs" | sed '1d' | awk '{ print $1 }' | sort -n)"
  SUM_MEDIAN="$(printf '%s\n' "$rest" | awk '{ a[NR] = $1 } END { if (NR % 2) m = a[(NR + 1) / 2]; else m = (a[NR / 2] + a[NR / 2 + 1]) / 2; printf "%.2f", m }')"
  echo "2회째부터 $((N - 1))회: 실행 시간 중앙값 $SUM_MEDIAN ms (최소 $(printf '%s\n' "$rest" | head -1 | awk '{ printf "%.2f", $1 }') / 최대 $(printf '%s\n' "$rest" | tail -1 | awk '{ printf "%.2f", $1 }') ms), 마지막 실행의 버퍼 hit=$(printf '%s\n' "$runs" | tail -1 | awk '{ print $3 }') read=$(printf '%s\n' "$runs" | tail -1 | awk '{ print $4 }')"
}

measure_file "$F1" "$N1"
summarize "$N1"
if [ $COMPARE = 1 ]; then
  m1="$SUM_MEDIAN"
  echo
  measure_file "$F2" "$N2"
  summarize "$N2"
  m2="$SUM_MEDIAN"
  echo
  echo "비교: 실행 시간 중앙값 $m1 ms → $m2 ms ($(awk -v a="$m1" -v b="$m2" 'BEGIN { if (a > 0) printf "%.2f배", b / a; else print "비교 불가" }'))"
fi
echo "알림: 시간은 실행할 때마다, 컴퓨터마다 달라집니다 — 같은 컴퓨터에서 연달아 잰 값끼리 견주세요." >&2
exit 0
