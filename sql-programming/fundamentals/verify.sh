#!/usr/bin/env bash
# 검증 러너 — 챕터 예제·문제를 world 위에서 실행하고 기대 출력과 대조한다.
# 이 코스를 만드는 쪽(챕터 작성·검증)이 사용한다 — 마지막 평가 장의 자동 검증도 이 러너로.
#
# 사용법:
#   ./verify.sh [케이스 디렉토리]          # 실행·대조 (기본: ./cases)
#   ./verify.sh --update [케이스 디렉토리] # 기대 출력(.expected) 재생성
#
#   두 경로 모두에서 동작한다 (kit_psql.sh):
#     KIT_MODE=docker (기본)  컨테이너 안의 psql
#     KIT_MODE=native         호스트에 설치한 psql
#
# 케이스 규약:
#   <이름>.sql       실행할 질의 파일. psql 한 세션으로 실행된다.
#   <이름>.expected  기대 출력 (psql 출력 + 마지막 줄 "[exit N]").
#   첫 줄에 "-- runner: reset"이 있으면 실행 전에 world를 초기화한다
#   (변경형 케이스 — DML·트랜잭션·exit assessment). 실행 후에도 남은
#   변경이 다음 케이스를 오염시키지 않도록, 변경형 케이스 뒤에는
#   자동으로 한 번 더 초기화한다.
#   오류를 기대하는 케이스는 오류 메시지와 0이 아닌 exit를 .expected에
#   담는다 (ON_ERROR_STOP=1).
#   전사(transcript) 케이스는 지원하지 않는다 — HARNESS.md 「검증 러너 규약」.
#
# 동시 실행 보호: 같은 world를 향한 다른 러너가 돌고 있으면 기다리지 않고
#   종료 코드 2로 거절한다 (kit_psql.sh 「러너 동시 실행 보호」).
set -uo pipefail
cd "$(dirname "$0")"
. ./kit_psql.sh

DB="$KIT_DB"

MODE=run
if [ "${1:-}" = "--update" ]; then MODE=update; shift; fi
DIR="${1:-cases}"
[ -d "$DIR" ] || { echo "오류: 케이스 디렉토리 없음: $DIR" >&2; exit 2; }

shopt -s nullglob
files=("$DIR"/*.sql)
[ ${#files[@]} -gt 0 ] || { echo "오류: $DIR 에 .sql 케이스가 없습니다" >&2; exit 2; }

kit_lock_acquire   # 다른 러너가 돌고 있으면 여기서 2로 끝난다

run_case() { # $1=sql파일 → stdout: 실행 출력 + "[exit N]"
  local out rc
  out=$(kit_psql -d "$DB" -X -q -v ON_ERROR_STOP=1 --pset pager=off < "$1" 2>&1)
  rc=$?
  printf '%s\n[exit %d]\n' "$out" "$rc"
}

pass=0; failed=0; failed_names=()
for sql in "${files[@]}"; do
  name=$(basename "$sql" .sql)
  expected="${sql%.sql}.expected"
  is_reset=0
  head -1 "$sql" | grep -q -- '-- runner: reset' && is_reset=1
  [ $is_reset = 1 ] && ./reset.sh >/dev/null

  actual=$(run_case "$sql")

  [ $is_reset = 1 ] && ./reset.sh >/dev/null

  if [ "$MODE" = update ]; then
    printf '%s' "$actual" > "$expected"
    echo "갱신: $name"
    continue
  fi

  if [ ! -f "$expected" ]; then
    echo "FAIL $name — 기대 파일 없음 ($expected). --update로 생성하세요."
    failed=$((failed+1)); failed_names+=("$name"); continue
  fi
  if diff_out=$(diff -u "$expected" <(printf '%s' "$actual")); then
    echo "PASS $name"; pass=$((pass+1))
  else
    echo "FAIL $name"
    echo "$diff_out" | sed 's/^/    /'
    failed=$((failed+1)); failed_names+=("$name")
  fi
done

[ "$MODE" = update ] && exit 0
echo "----"
echo "결과: PASS $pass / FAIL $failed"
if [ $failed -gt 0 ]; then
  echo "실패 케이스: ${failed_names[*]}"
  exit 1
fi
