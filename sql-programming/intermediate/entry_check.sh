#!/usr/bin/env bash
# 입장 점검(entry check) — 이 코스를 시작할 준비가 되었는지 확인한다 (0장 0.5절).
#
#   1단계  환경 확인 (./check_env.sh): 접속·버전·world 속성.
#   2단계  네 문항 채점: entry/q1.sql ~ entry/q4.sql 에 여러분이 적은 SQL 을 world 위에서
#          실행해 기대 결과와 대조한다. 문항은 각 파일의 머리 주석에 있다.
#            q1  단일 테이블 조회   q2  조인   q3  집계   q4  변경 + 트랜잭션
#          q4 는 world 를 바꾸므로 실행 전후에 ./reset.sh 로 되돌린다.
#
# 사용법:
#   ./entry_check.sh              # 여러분의 답(entry/q1.sql ~ q4.sql)을 채점
#   ./entry_check.sh --reference  # kit 에 든 참조 해답(entry/reference/)으로 자가 시험 — 기대 결과가
#                                 #   world 와 맞는지 확인하는 용도이며, 여러분의 답은 보지 않는다
#
# 판정: 네 문항 모두 통과하면 「입장 점검 통과」와 종료 코드 0. 하나라도 다르면 문항별로
# 무엇이 달랐는지(diff)와 **돌아가 볼 fundamentals 코스의 장**을 알리고 종료 코드 1.
# 환경 자체가 안 되면 check_env.sh 의 원인·다음 행동 문구가 그대로 나온다.
#
# 비교 방식: psql 의 기본 표 출력을 글자 그대로 대조한다. 그래서 문항이 정한 **열 이름·
# 열 차례·정렬 차례**를 지켜야 한다 — 값이 같아도 열 이름이 다르면 다르게 읽는다.
# 이것은 fundamentals exit assessment 의 자동 검증 문항과 같은 방식이다.
set -uo pipefail
cd "$(dirname "$0")"
. ./kit_psql.sh

DB="$KIT_DB"
ANSWERS=entry
if [ "${1:-}" = "--reference" ]; then ANSWERS=entry/reference; shift; fi
[ $# -eq 0 ] || { echo "사용법: ./entry_check.sh [--reference]" >&2; exit 2; }

# 돌아가 볼 곳 (fundamentals 코스의 장)
back_for() {
  case "$1" in
    q1) echo "fundamentals 2장(원하는 열 고르기 — SELECT)·3장(원하는 행 고르기 — WHERE)·4장(순서 매기고 개수 줄이기 — ORDER BY·LIMIT)" ;;
    q2) echo "fundamentals 7장(테이블 연결하기 — 조인)·8장(조인 넓히기 — OUTER 조인과 다중 조인)" ;;
    q3) echo "fundamentals 9장(요약하기 — 집계)" ;;
    q4) echo "fundamentals 11장(데이터 넣고 고치고 지우기 — DML)·12장(전부 되거나 전부 안 되거나 — 트랜잭션)" ;;
  esac
}

kit_runtime_check "entry check"

echo "== 1단계: 환경 확인"
./check_env.sh || exit 1

echo "== 2단계: 네 문항 채점 ($ANSWERS/q1.sql ~ q4.sql)"
kit_lock_acquire   # q4 가 world 를 바꾸므로, 같은 world 를 쓰는 다른 실행과 겹치지 않게

run_sql() { # $1=sql 파일 → stdout: psql 출력(+오류), 반환 코드는 psql 의 것
  kit_psql -d "$DB" -X -q -v ON_ERROR_STOP=1 --pset pager=off < "$1" 2>&1
}

has_sql() { # 파일에 주석·빈 줄 말고 내용이 있는가
  grep -vE '^\s*(--.*)?$' "$1" | grep -q .
}

pass=0; fail=0; failed=()
for q in q1 q2 q3 q4; do
  ans="$ANSWERS/$q.sql"; exp="entry/expected/$q.expected"
  if [ ! -f "$ans" ]; then
    echo "FAIL $q — 답 파일이 없습니다: $ans"; fail=$((fail+1)); failed+=("$q"); continue
  fi
  if ! has_sql "$ans"; then
    echo "FAIL $q — 아직 답을 적지 않았습니다 ($ans 의 주석 아래에 SQL 을 적어 주세요)"
    fail=$((fail+1)); failed+=("$q"); continue
  fi

  if [ "$q" = q4 ]; then
    # 변경형: 되돌리고 → 여러분의 트랜잭션 실행 → 확인 질의의 결과를 대조 → 되돌린다
    ./reset.sh >/dev/null || { echo "오류: q4 실행 전 world 초기화에 실패했습니다 (위 reset 메시지 참고)." >&2; exit 2; }
    if ! out=$(run_sql "$ans"); then
      echo "FAIL $q — 실행 중 오류:"; printf '%s\n' "$out" | sed 's/^/    /'
      fail=$((fail+1)); failed+=("$q")
      ./reset.sh >/dev/null; continue
    fi
    actual=$(run_sql entry/q4_check.sql; printf '[exit %d]' "$?")
    ./reset.sh >/dev/null || { echo "오류: q4 실행 후 world 초기화에 실패했습니다 (위 reset 메시지 참고)." >&2; exit 2; }
  else
    actual=$(run_sql "$ans"; printf '[exit %d]' "$?")
  fi

  if diff_out=$(diff -u --label 기대 --label 실제 "$exp" <(printf '%s' "$actual")); then
    echo "PASS $q"; pass=$((pass+1))
  else
    echo "FAIL $q — 기대한 결과와 다릅니다 (- 기대, + 실제):"
    echo "$diff_out" | sed 's/^/    /'
    fail=$((fail+1)); failed+=("$q")
  fi
done

echo "----"
if [ $fail -eq 0 ]; then
  echo "입장 점검 통과: 환경 확인 + 4문 전량 통과. 1장으로 가셔도 됩니다."
  exit 0
fi
echo "입장 점검 미통과: PASS $pass / FAIL $fail"
for q in "${failed[@]}"; do
  echo "  $q → 돌아가 볼 곳: $(back_for "$q")"
done
echo "  다음: 위 장을 복습한 뒤 $ANSWERS/<문항>.sql 을 고쳐 ./entry_check.sh 를 다시 실행하세요. 열 이름·차례·정렬이 문항과 같은지 먼저 확인하세요."
exit 1
