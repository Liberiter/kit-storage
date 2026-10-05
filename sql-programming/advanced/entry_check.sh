#!/usr/bin/env bash
# 입장 점검(entry check) — 이 코스를 시작할 준비가 되었는지 확인한다 (0장 0.5절).
#
#   1단계  환경 확인 (./check_env.sh): 접속·버전·world 속성.
#   2단계  네 문항 채점: entry/q1.sql ~ entry/q4.sql 에 여러분이 적은 SQL 을 world 위에서
#          실행해 기대 결과와 대조한다. 문항은 각 파일의 머리 주석에 있다.
#          이 파일들은 ./setup.sh 가 만들어 두며, 한 번 만든 뒤로는 다시 구축해도 덮이지
#          않는다 — 여러분이 적어 두신 답이 그대로 남는다.
#            q1  복합 보고서 질의   q2  스키마·제약 설계   q3  결함 있는 질의 교정
#            q4  실행 계획의 스캔 유형 + 격리 수준 고르기
#          q2 는 테이블을 만들므로 실행 전후에 ./reset.sh 로 되돌리고, 여러분의 DDL 뒤에
#          entry/q2_check.sql 이 맞는 행과 어긋난 행을 넣어 보는 결과를 대조한다.
#
# 사용법:
#   ./entry_check.sh              # 여러분의 답(entry/q1.sql ~ q4.sql)을 채점
#   ./entry_check.sh --reference  # kit 에 든 참조 해답(entry/reference/)으로 자가 시험 — 기대 결과가
#                                 #   world 와 맞는지 확인하는 용도이며, 여러분의 답은 보지 않는다
#
# 판정: 네 문항 모두 통과하면 「입장 점검 통과」와 종료 코드 0. 하나라도 다르면 문항별로
# 무엇이 달랐는지(diff)와 **돌아가 볼 intermediate 코스의 장**을 알리고 종료 코드 1.
# 환경 자체가 안 되면 check_env.sh 의 원인·다음 행동 문구가 그대로 나온다.
#
# 비교 방식: psql 의 기본 표 출력을 글자 그대로 대조한다. 그래서 문항이 정한 **열 이름·
# 열 차례·정렬 차례**를 지켜야 한다 — 값이 같아도 열 이름이 다르면 다르게 읽는다.
# 이 스크립트는 프로세스 치환(bash 전용)을 쓰므로, 그것이 안 되는 셸에서는 채점을
# 한 건도 하지 않고 거절한다. `sh entry_check.sh`로 부르면 구문 오류를 내면서도 네
# 문항을 다 틀린 것처럼 보여, 채점이 아예 돌지 않은 것을 앞 코스로 돌아가라는 안내로
# 읽게 된다. 0건 실행은 성공도 전량 실패도 아니므로 종료 코드 2(실행 오류)로 가른다.
# `$BASH_VERSION`으로는 가를 수 없다: macOS의 `sh`는 POSIX 모드의 bash라 변수가
# 설정되어 있는데도 프로세스 치환이 꺼져 있다.
if ! (eval ': <(:)') 2>/dev/null; then
  echo "오류: 이 스크립트는 프로세스 치환을 지원하는 bash가 필요합니다 — 지금 셸에서는 꺼져 있어 채점을 시작하지 않았습니다." >&2
  echo "  다음: ./entry_check.sh 또는 bash entry_check.sh 로 실행하세요 (sh entry_check.sh 는 POSIX 모드라 동작하지 않습니다)." >&2
  exit 2
fi

set -uo pipefail
cd "$(dirname "$0")"
# 이 줄도 «셸이» 파일을 읽는 자리다 — 없으면 셸이 먼저 실패하고 kit의 문구가 나올
# 자리가 없다(0장 0.6). fail()·kit_psql 이 아직 없으므로 직접 낸다.
[ -r ./kit_psql.sh ] || {
  echo "오류: kit 파일 kit_psql.sh 을(를) 읽을 수 없습니다." >&2
  echo "  다음: 파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)." >&2
  exit 2; }
. ./kit_psql.sh

DB="$KIT_DB"
ANSWERS=entry
if [ "${1:-}" = "--reference" ]; then ANSWERS=entry/reference; shift; fi
[ $# -eq 0 ] || { echo "사용법: ./entry_check.sh [--reference]" >&2; exit 2; }

# 돌아가 볼 곳 (intermediate 코스의 장)
back_for() {
  case "$1" in
    q1) echo "intermediate 1장(요구사항을 질의로 — 분해·조건 논리·조건 집계)·3장(질의 구조화 — CTE와 LATERAL)·4장(집계 심화 — 통계 집계와 윈도우 함수 입문)·5장(순위·추세·프레임 — 윈도우 함수 활용)" ;;
    q2) echo "intermediate 6장(스키마 설계와 정규화)·7장(정합성을 설계하기 — 제약·UPSERT)" ;;
    q3) echo "intermediate 2장(조인 전략 — 선택과 함정)·8장(안티패턴 — 흔한 설계·질의 실수)" ;;
    q4) echo "intermediate 11장(질의는 빠른가 — 인덱스와 EXPLAIN 입문)·12장(같이 써도 안전한가 — 격리 수준과 동시성)" ;;
  esac
}

# 이 스크립트가 부르는 kit 스크립트 — 없거나 실행할 수 없으면 셸이 「No such file」·「Permission denied」 한 줄만
# 내고 그 rc(1·126·127)가 「입장 점검 미통과」와 섞이므로, 무엇을 하기 전에 먼저 보고 2 로 끝낸다.
for _f in check_env.sh reset.sh; do
  [ -f "./$_f" ] && [ -x "./$_f" ] || {
    echo "오류: kit 파일 $_f 을(를) 실행할 수 없습니다 (없거나 실행 권한이 없습니다)." >&2
    echo "  다음: 파일이 지워졌다면 kit을 다시 받으세요 (0장 0.3절). 파일은 있는데 권한이 없으면 chmod +x $_f 뒤 다시 실행하세요." >&2
    exit 2; }
done

kit_runtime_check "entry check"

# 채점이 읽는 kit 파일 — 기대 결과(entry/expected/qN.expected)와 q2 의 확인 질의(entry/q2_check.sql).
# 없으면 diff·셸 리디렉션이 실패하고, 그 실패가 「FAIL qN — 기대한 결과와 다릅니다」로 읽혀 여러분의 답이
# 틀린 것처럼 보인다(답은 채점되지도 않았다). 그래서 채점을 시작하기 전에 먼저 확인한다 — 1단계(환경
# 확인)보다 앞에 두어 잠금을 잡기 전에 멈춘다 (reset.sh 의 같은 가드와 같은 문구).
for _f in entry/expected/q1.expected entry/expected/q2.expected entry/expected/q3.expected entry/expected/q4.expected entry/q2_check.sql; do
  [ -r "$_f" ] || {
    echo "오류: kit 파일 $_f 을(를) 읽을 수 없습니다." >&2
    echo "  다음: 파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)." >&2
    exit 2; }
done

echo "== 1단계: 환경 확인"
./check_env.sh || exit 1

echo "== 2단계: 네 문항 채점 ($ANSWERS/q1.sql ~ q4.sql)"
kit_lock_acquire   # q2 가 world 를 바꾸므로, 같은 world 를 쓰는 다른 실행과 겹치지 않게

run_sql() { # $1=sql 파일 → stdout: psql 출력(+오류), 반환 코드는 psql 의 것
  # 표준 출력과 오류는 psql 쪽에서 합친다 (kit_psql.sh kit_psql_merged) — 호스트에서 합치면
  # 경고 줄과 결과표의 차례가 실행마다 갈릴 수 있다.
  kit_psql_merged -d "$DB" -X -q -v ON_ERROR_STOP=1 --pset pager=off < "$1"
}

has_sql() { # 파일에 주석·빈 줄 말고 내용이 있는가
  grep -vE '^\s*(--.*)?$' "$1" | grep -q .
}

pass=0; fail=0; failed=()
for q in q1 q2 q3 q4; do
  ans="$ANSWERS/$q.sql"; exp="entry/expected/$q.expected"
  if [ ! -f "$ans" ]; then
    echo "FAIL $q — 답 파일이 없습니다: $ans"
    if [ "$ANSWERS" = entry ]; then
      echo "  다음: ./setup.sh 를 한 번 실행하시면 문항 파일을 다시 만들어 드립니다 (이미 있는 파일은 그대로 둡니다)."
    fi
    fail=$((fail+1)); failed+=("$q"); continue
  fi
  if ! has_sql "$ans"; then
    echo "FAIL $q — 아직 답을 적지 않았습니다 ($ans 의 주석 아래에 SQL 을 적어 주세요)"
    fail=$((fail+1)); failed+=("$q"); continue
  fi

  if [ "$q" = q2 ]; then
    # 변경형: 되돌리고 → 여러분의 DDL 실행 → 확인 질의의 결과를 대조 → 되돌린다
    ./reset.sh >/dev/null || {
      echo "오류: q2 실행 전 world 초기화에 실패했습니다 (위 reset 메시지 참고)." >&2
      echo "  다음: ./reset.sh 를 직접 실행해 원인을 확인하세요. 그래도 막히면 ./setup.sh 로 world를 처음 상태로 다시 세운 뒤 다시 실행하세요." >&2
      exit 2; }
    if ! out=$(run_sql "$ans"); then
      echo "FAIL $q — 실행 중 오류:"; printf '%s\n' "$out" | sed 's/^/    /'
      fail=$((fail+1)); failed+=("$q")
      ./reset.sh >/dev/null || {
        echo "오류: q2 실행 후 world 초기화에 실패했습니다 (위 reset 메시지 참고)." >&2
        echo "  다음: ./reset.sh 를 직접 실행해 원인을 확인하세요. 그래도 막히면 ./setup.sh 로 world를 처음 상태로 다시 세운 뒤 다시 실행하세요." >&2
        exit 2; }
      continue
    fi
    actual=$(run_sql entry/q2_check.sql; printf '[exit %d]' "$?")
    ./reset.sh >/dev/null || {
      echo "오류: q2 실행 후 world 초기화에 실패했습니다 (위 reset 메시지 참고)." >&2
      echo "  다음: ./reset.sh 를 직접 실행해 원인을 확인하세요. 그래도 막히면 ./setup.sh 로 world를 처음 상태로 다시 세운 뒤 다시 실행하세요." >&2
      exit 2; }
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
