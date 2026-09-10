#!/usr/bin/env bash
# 동시성 이상 현상 재현 — psql 세션 둘을 엇갈려 실행한다 (12장).
#
# 두 가지 쓰임새가 있다.
#
# (1) 자동 재현 — 이 스크립트가 두 세션을 열어 정해진 차례로 문장을 보내고, 엇갈린 전사를
#     찍은 뒤 결과를 판정한다.
#       ./concurrency.sh lost-update          [read-committed|repeatable-read]
#       ./concurrency.sh nonrepeatable-read   [read-committed|repeatable-read]
#     격리 수준을 생략하면 read-committed (PostgreSQL 기본값).
#     종료 코드: 0 = 그 격리 수준에서 기대한 대로 되었다 (read-committed 에서는 이상 현상이
#     **재현**되고, repeatable-read 에서는 **차단**된다) / 1 = 기대와 다르다 / 2 = 실행 오류.
#     끝나면 1번 책의 재고를 원래 값으로 되돌린다 (world 의 다른 부분은 건드리지 않는다).
#
# (2) 두 터미널에서 직접 따라 하기 — 터미널을 둘 열고 각각 A·B 세션을 띄운다.
#       터미널 1:  ./concurrency.sh --terminal A lost-update [격리 수준]
#       터미널 2:  ./concurrency.sh --terminal B lost-update [격리 수준]
#     각 세션은 concurrency/<시나리오>_a.sql / _b.sql 을 한 단계씩 실행하며, 상대 터미널에서
#     할 일을 안내하고 Enter 를 기다린다. 끝나면 1번 책의 재고를 ./reset.sh 로 되돌리세요
#     (두 세션이 남긴 변경을 함께 지운다).
#
# 두 경로(기본 Docker / 대안 직접 설치) 모두에서 동작한다 — kit_psql.sh 가 psql 을 고른다.
# 기본 경로에서는 setup.sh 가 concurrency/ 를 컨테이너 안 /kit/concurrency 에 복사해 두었다.
set -uo pipefail
cd "$(dirname "$0")"
. ./kit_psql.sh

DB="$KIT_DB"
BOOK=1   # 실습 대상 책 — concurrency/*.sql 의 \set book_id 와 같아야 한다

usage() {
  echo "사용법: ./concurrency.sh <lost-update|nonrepeatable-read> [read-committed|repeatable-read]" >&2
  echo "        ./concurrency.sh --terminal <A|B> <lost-update|nonrepeatable-read> [read-committed|repeatable-read]" >&2
  exit 2
}

TERMINAL=""
if [ "${1:-}" = "--terminal" ]; then
  TERMINAL="$(echo "${2:-}" | tr 'ab' 'AB')"; shift 2
  case "$TERMINAL" in A|B) ;; *) usage ;; esac
fi
SCENARIO="${1:-}"; LEVEL="${2:-read-committed}"
case "$SCENARIO" in lost-update|nonrepeatable-read) ;; *) usage ;; esac
case "$LEVEL" in
  read-committed)  ISO="READ COMMITTED" ;;
  repeatable-read) ISO="REPEATABLE READ" ;;
  *) usage ;;
esac
[ $# -le 2 ] || usage

# 실행 전 점검 — 런타임·컨테이너(또는 psql)·접속. 둘 다 종료 코드 2(머리 주석의 「2 = 실행 오류」).
kit_runtime_check "concurrency" 2
# 서버에 접속되는지도 여기서 한 번 본다 — 두 터미널 모드가 대안 경로에서 서버가 내려가 있을 때
# psql 의 접속 오류만 찍고 「다음:」 없이 끝나지 않게 한다. 종료 코드는 자동 모드의 실행 오류와
# 같은 2 (check_env.sh 와 같은 「psql 접속 불가」 문구, kit_psql.sh kit_connect_check).
kit_connect_check "concurrency" 2

# ---------- (2) 두 터미널 모드: 해당 세션의 스크립트를 터미널에 붙여 실행하고 끝 ----------
if [ -n "$TERMINAL" ]; then
  file="$(echo "$SCENARIO" | tr '-' '_')_$(echo "$TERMINAL" | tr 'AB' 'ab').sql"
  if [ "$KIT_MODE" = native ]; then
    path="concurrency/$file"
  else
    path="/kit/concurrency/$file"
    docker exec "$KIT_CONTAINER" test -f "$path" 2>/dev/null || {
      echo "concurrency 실패: 컨테이너 안에 $path 가 없습니다 (setup.sh 가 복사해 둡니다)" >&2
      echo "  다음: ./setup.sh 를 한 번 실행한 뒤 다시 시도하세요." >&2; exit 2; }
  fi
  echo "세션 $TERMINAL — $SCENARIO ($ISO). 상대 터미널에서는 --terminal $([ "$TERMINAL" = A ] && echo B || echo A) 로 같은 시나리오를 띄우세요."
  exec_psql() { kit_psql_tty -d "$DB" -X -v ON_ERROR_STOP=0 --pset pager=off -v iso="$ISO" -v book_id="$BOOK" -f "$path"; }
  exec_psql
  exit $?
fi

# ---------- (1) 자동 재현 ----------
kit_lock_acquire   # world 를 바꾸므로 러너·다른 재현과 겹치지 않게

WORK="$(mktemp -d "${TMPDIR:-/tmp}/ll-concurrency.XXXXXX")"
cleanup_work() { rm -rf "$WORK"; }

# 세션 하나를 이름 붙인 파이프 위에 띄운다. 표준 입력은 fd 3(A)·5(B), 출력은 fd 4(A)·6(B).
#
# psql 의 stdout(질의 결과·\echo 표식)과 stderr(ERROR 줄)는 **psql 과 같은 쪽에서** 하나로
# 합쳐야 한다. 기본 경로에서 `docker exec … 2>&1` 처럼 호스트에서 합치면, docker 가 두
# 스트림을 따로 다중화해 돌려주므로 호스트에 닿는 차례가 보장되지 않는다 — ERROR 줄이
# 표식(__DONE__) 뒤에 도착해 다음 단계 아래 찍히고 판정이 「기대와 다름」으로 어긋나는 일이
# 간헐적으로 있었다(실측 6회 중 2회). 컨테이너 안에서 sh 가 합치면 psql 이 쓴 차례 그대로다.
open_psql_merged() { # 인자는 psql 옵션. stdout+stderr 를 psql 쪽에서 합쳐 한 스트림으로 낸다.
  if [ "$KIT_MODE" = native ]; then
    "$KIT_PSQL" "$@" 2>&1
  else
    docker exec -i "$KIT_CONTAINER" sh -c 'exec psql -U postgres "$@" 2>&1' sh "$@"
  fi
}
open_session() { # $1=A|B
  local in="$WORK/$1.in" out="$WORK/$1.out"
  mkfifo "$in" "$out"
  open_psql_merged -d "$DB" -X -v ON_ERROR_STOP=0 --pset pager=off -v iso="$ISO" -v book_id="$BOOK" < "$in" > "$out" &
  if [ "$1" = A ]; then exec 3>"$in" 4<"$out"; else exec 5>"$in" 6<"$out"; fi
}

send() { # $1=A|B, $2=보낼 문장들 (여러 줄 가능). 끝에 표식을 덧붙인다.
  local fd=3; [ "$1" = B ] && fd=5
  printf '%s\n\\echo __DONE__\n' "$2" >&$fd
}

# 표식(__DONE__)이 나올 때까지 세션 출력을 읽어 "[A] " 접두로 찍고, 전체를 변수 LAST 에 담는다.
# 잠겨서 오래 기다리는 문장(UPDATE 가 다른 세션의 락을 기다림)을 위해 제한 시간을 둔다.
LAST=""
collect() { # $1=A|B, $2=제한 시간(초, 기본 15)
  local fd=4 line; [ "$1" = B ] && fd=6
  LAST=""
  while IFS= read -r -t "${2:-15}" -u $fd line; do
    [ "$line" = "__DONE__" ] && return 0
    echo "[$1] $line"
    LAST+="$line"$'\n'
  done
  echo "concurrency 실패: 세션 $1 의 응답을 ${2:-15}초 안에 받지 못했습니다 (문장이 다른 세션의 락에 막혀 있을 수 있습니다)" >&2
  echo "  다음: 열어 둔 다른 psql 세션이 books 테이블을 잠그고 있지 않은지 확인한 뒤(pg_stat_activity), ./reset.sh 로 되돌리고 다시 실행하세요." >&2
  close_sessions; cleanup_work; exit 2
}

step() { # $1=A|B, $2=사람에게 보일 단계 설명, $3=문장들, [$4=제한 시간]
  echo; echo "── $1: $2"
  send "$1" "$3"
  collect "$1" "${4:-15}"
}

close_sessions() {
  exec 3>&- 5>&- 2>/dev/null || true
  sleep 0.2
  exec 4<&- 6<&- 2>/dev/null || true
  wait 2>/dev/null || true
}

restore_stock() { # 실습 대상 책의 재고를 원래 값으로
  kit_psql -d "$DB" -X -q -c "UPDATE books SET stock = $INITIAL WHERE book_id = $BOOK;" >/dev/null 2>&1 \
    || { echo "알림: 재고를 되돌리지 못했습니다 — ./reset.sh 로 world 를 되돌리세요." >&2; }
}

INITIAL="$(kit_psql -d "$DB" -X -tAc "SELECT stock FROM books WHERE book_id = $BOOK" 2>/dev/null | tr -d '[:space:]')"
case "$INITIAL" in ''|*[!0-9]*)
  echo "concurrency 실패: ${BOOK}번 책의 재고를 읽지 못했습니다 (데이터베이스 $DB)" >&2
  echo "  다음: ./check_env.sh 로 접속과 world 상태를 확인하세요." >&2; cleanup_work; exit 2 ;;
esac
if [ "$INITIAL" -lt 2 ]; then
  echo "concurrency 실패: ${BOOK}번 책의 재고가 $INITIAL 이라 두 번 팔 수 없습니다" >&2
  echo "  다음: ./reset.sh 로 world 를 초기 상태(재고 5)로 되돌린 뒤 다시 실행하세요." >&2; cleanup_work; exit 2
fi

echo "시나리오: $SCENARIO / 격리 수준: $ISO / 대상: ${BOOK}번 책 (재고 $INITIAL)"
echo "두 세션 A·B 를 열고 문장을 엇갈려 보냅니다. 각 줄의 [A]·[B] 는 그 세션의 psql 출력입니다."

open_session A
open_session B
trap 'close_sessions; cleanup_work; kit_lock_release' EXIT   # 잠금 해제 trap 을 덮어쓰므로 함께 부른다

verdict=1
case "$SCENARIO" in
  lost-update)
    # 갱신 손실(lost update): 두 세션이 같은 재고를 읽고, 각자 「읽은 값 − 1」을 쓴다.
    # 두 권이 팔렸는데 재고는 한 권만 줄어든다 — READ COMMITTED 에서 일어난다.
    step A "트랜잭션 시작, 재고 읽기" "BEGIN;
SET TRANSACTION ISOLATION LEVEL $ISO;
SELECT stock FROM books WHERE book_id = $BOOK \\gset a_
\\echo A가 읽은 재고: :a_stock"
    step B "트랜잭션 시작, 재고 읽기 (A 가 아직 커밋하지 않았다)" "BEGIN;
SET TRANSACTION ISOLATION LEVEL $ISO;
SELECT stock FROM books WHERE book_id = $BOOK \\gset b_
\\echo B가 읽은 재고: :b_stock"
    step A "읽은 값에서 1 을 뺀 값을 쓴다 (한 권 판매)" "UPDATE books SET stock = :a_stock - 1 WHERE book_id = $BOOK;"
    echo; echo "── B: 읽은 값에서 1 을 뺀 값을 쓴다 — A 가 같은 행을 잠그고 있어 A 가 끝날 때까지 기다린다"
    send B "UPDATE books SET stock = :b_stock - 1 WHERE book_id = $BOOK;"
    sleep 0.5
    step A "커밋 — 이제 B 의 UPDATE 가 풀린다" "COMMIT;"
    echo; echo "── B: 기다리던 UPDATE 의 결과"
    collect B 15
    b_update="$LAST"
    step B "커밋" "COMMIT;"
    step A "최종 재고 확인" "SELECT stock AS final_stock FROM books WHERE book_id = $BOOK;"
    final="$(kit_psql -d "$DB" -X -tAc "SELECT stock FROM books WHERE book_id = $BOOK" | tr -d '[:space:]')"
    echo
    if [ "$LEVEL" = read-committed ]; then
      if [ "$final" = "$((INITIAL - 1))" ]; then
        echo "결과: 갱신 손실 재현됨 — 두 권이 팔렸는데 재고는 $INITIAL → $final (한 권만 줄었습니다). B 의 UPDATE 가 A 의 결과를 덮어썼습니다."
        verdict=0
      else
        echo "결과: 기대와 다름 — READ COMMITTED 에서 재고가 $INITIAL → $final 이 되었습니다 (갱신 손실이면 $((INITIAL - 1)) 이어야 합니다)."
      fi
    else
      if printf '%s' "$b_update" | grep -q "could not serialize access due to concurrent update"; then
        echo "결과: 갱신 손실 차단됨 — REPEATABLE READ 가 B 의 UPDATE 를 오류(could not serialize access due to concurrent update)로 거절했습니다. 재고 $INITIAL → $final (A 의 판매만 반영)."
        verdict=0
      else
        echo "결과: 기대와 다름 — REPEATABLE READ 에서 B 의 UPDATE 가 거절되지 않았습니다 (재고 $INITIAL → $final)."
      fi
    fi
    ;;
  nonrepeatable-read)
    # 반복 불가능 읽기(nonrepeatable read): 한 트랜잭션 안에서 같은 행을 두 번 읽었는데
    # 사이에 다른 세션이 커밋한 변경 때문에 값이 달라진다 — READ COMMITTED 에서 일어난다.
    step A "트랜잭션 시작, 재고 첫 번째 읽기" "BEGIN;
SET TRANSACTION ISOLATION LEVEL $ISO;
SELECT stock AS first_read FROM books WHERE book_id = $BOOK;"
    step B "다른 세션이 한 권 팔고 바로 커밋 (자동 커밋)" "UPDATE books SET stock = stock - 1 WHERE book_id = $BOOK;"
    step A "같은 트랜잭션 안에서 재고 두 번째 읽기" "SELECT stock AS second_read FROM books WHERE book_id = $BOOK;"
    second="$(printf '%s' "$LAST" | grep -E '^\s*[0-9]+\s*$' | tail -1 | tr -d '[:space:]')"
    step A "커밋" "COMMIT;"
    echo
    if [ "$LEVEL" = read-committed ]; then
      if [ "$second" = "$((INITIAL - 1))" ]; then
        echo "결과: 반복 불가능 읽기 재현됨 — 같은 트랜잭션 안에서 첫 읽기 $INITIAL, 두 번째 읽기 $second. 사이에 커밋된 B 의 변경이 보였습니다."
        verdict=0
      else
        echo "결과: 기대와 다름 — READ COMMITTED 에서 두 번째 읽기가 $second 입니다 (재현되면 $((INITIAL - 1)) 이어야 합니다)."
      fi
    else
      if [ "$second" = "$INITIAL" ]; then
        echo "결과: 반복 불가능 읽기 차단됨 — REPEATABLE READ 에서 두 번 읽은 값이 $INITIAL 로 같습니다 (B 의 커밋은 트랜잭션이 시작한 뒤의 일이라 보이지 않습니다)."
        verdict=0
      else
        echo "결과: 기대와 다름 — REPEATABLE READ 에서 두 번째 읽기가 $second 입니다 (첫 읽기 $INITIAL 과 같아야 합니다)."
      fi
    fi
    ;;
esac

close_sessions
restore_stock
echo "정리: ${BOOK}번 책의 재고를 $INITIAL 로 되돌렸습니다."
exit $verdict
