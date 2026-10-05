#!/usr/bin/env bash
# 두 세션 재현 — psql 세션 둘(A·B)을 열어 시나리오 파일의 문장을 정해진 차례로 보낸다.
# 잠금 대기·데드락·직렬화 실패·긴 트랜잭션 같은, 세션 둘이 엇갈려야 나오는 거동을 누가 언제
# 돌려도 같은 차례로 재현하는 도구다 (10·11장, 마지막 평가 장의 동시성 문항).
#
# 사용법:
#   ./sessions.sh scenarios/deadlock.sql          # kit 에 든 시나리오
#   ./sessions.sh 내가-쓴-시나리오.sql            # 여러분이 쓴 시나리오도 같은 형식이면 된다
#   ./sessions.sh --keep scenarios/…sql           # 끝난 뒤 world 를 되돌리지 않는다 (상태를 들여다볼 때)
#
# 시작하기 전에 world 를 초기 상태로 되돌리고(./reset.sh), 끝나면 다시 되돌린다(--keep 이면 두지 않는다).
# 같은 world 를 쓰는 다른 실행(./verify.sh 등)과 겹치지 않게 잠금을 잡는다.
#
# ## 시나리오 파일 형식
#
# 「-- @」로 시작하는 줄이 지시다. 지시 아래의 줄들이 다음 지시 전까지 한 단계다.
#   -- @A            아래 문장들을 세션 A 에 보내고, 끝날 때까지 기다린다 (B 도 같다)
#   -- @A &          아래 문장들을 세션 A 에 보내되 끝나기를 기다리지 않는다. 그 문장이 **잠금을 기다리는
#                    상태가 된 것을 확인하고** 다음 단계로 간다. 잠금을 기다리지 않고 끝나 버리면 그것을
#                    기록하고 결과를 「기대와 다름」으로 판정한다 — 잠금 대기를 재현하려던 시나리오가
#                    재현되지 않은 것이기 때문이다.
#   -- @A wait       앞에서 「-- @A &」로 보낸 문장이 끝나기를 기다려 그 출력을 받는다
#   -- @observe      아래 질의를 A·B 와 다른 세 번째 연결에서 실행해 보여 준다 (pg_locks·pg_stat_activity 등)
#   -- @expect A ok      세션 A 의 모든 단계가 오류 없이 끝나야 한다
#   -- @expect B 40P01   세션 B 의 어느 단계가 그 오류 코드(SQLSTATE)로 끝나야 한다
#                        (40P01 데드락, 40001 직렬화 실패, 23505 고유 위반, 55P03 잠금 시한 초과 등)
# 단계 안의 「--」로 시작하는 줄은 세션에 보내지 않고 그 단계의 설명으로 화면에 찍는다.
# 오류 코드는 그 단계에서 **마지막으로 난 오류**의 것이다 — 판정하려는 문장을 단계의 끝에 두세요.
#
# 종료 코드: 0 = 끝까지 실행했고 기대(-- @expect, 그리고 「&」 단계의 잠금 대기)가 모두 맞았다
#            1 = 끝까지 실행했지만 기대와 다르다
#            2 = 실행 오류 (파일·형식·접속 문제, 세션이 시한 안에 응답하지 않음)
#
# 화면의 [A]·[B] 줄은 그 세션의 psql 출력이고, 보낸 문장도 함께 찍힌다. 프로세스 번호·트랜잭션 번호처럼
# 실행마다 달라지는 값이 오류 메시지의 DETAIL 줄 등에 섞여 나온다 — 판정은 그 줄이 아니라 오류 코드로 한다.
#
# 이 스크립트는 bash 전용 기능을 쓰므로, 그것이 꺼진 셸(sh sessions.sh)에서는 시작하지 않고 거절한다.
if ! (eval ': <(:)') 2>/dev/null; then
  echo "오류: 이 스크립트는 bash가 필요합니다 — 지금 셸에서는 bash 기능(프로세스 치환 등)이 꺼져 있어 재현을 시작하지 않았습니다." >&2
  echo "  다음: ./sessions.sh 또는 bash sessions.sh 로 실행하세요 (sh sessions.sh 는 POSIX 모드라 동작하지 않습니다)." >&2
  exit 2
fi

set -uo pipefail
cd "$(dirname "$0")"
[ -r ./kit_psql.sh ] || {
  echo "sessions 실패: kit 파일 kit_psql.sh 을(를) 읽을 수 없습니다." >&2
  echo "  다음: 파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)." >&2
  exit 2; }
. ./kit_psql.sh

DB="$KIT_DB"
KEEP=0

usage() {
  echo "사용법: ./sessions.sh [--keep] <시나리오 파일>" >&2
  echo "        (kit 에 든 시나리오는 scenarios/ 에 있습니다 — 예: ./sessions.sh scenarios/deadlock.sql)" >&2
  exit 2
}
fail2() { # $1=원인, $2=다음
  echo "sessions 실패: $1" >&2
  [ "${2:-}" = "" ] || echo "  다음: $2" >&2
  exit 2
}

if [ "${1:-}" = "--keep" ]; then KEEP=1; shift; fi
[ $# -eq 1 ] || usage
ARG="$1"
FILE="$1"
# 파일 경로는 부른 자리 기준일 수 있다 — 위에서 kit 폴더로 옮겨 왔으므로, 부른 자리의 경로를 먼저 본다.
case "$FILE" in
  /*) ;;
  *) [ -n "${OLDPWD:-}" ] && [ -r "$OLDPWD/$FILE" ] && FILE="$OLDPWD/$FILE" ;;
esac
[ -r "$FILE" ] || fail2 "시나리오 파일을 읽을 수 없습니다: $ARG" "파일 경로를 확인하세요 — kit 에 든 시나리오는 scenarios/ 에 있습니다 (ls scenarios)"

# ---------- 시나리오 읽기 (실행 전에 형식부터 전부 본다) ----------
KINDS=(); BODIES=(); LINES=(); EXPECT_S=(); EXPECT_V=()
cur_kind=""; cur_body=""; cur_line=0; lineno=0
flush() {
  if [ -n "$cur_kind" ]; then
    KINDS+=("$cur_kind"); BODIES+=("$cur_body"); LINES+=("$cur_line")
  fi
  cur_kind=""; cur_body=""
}
while IFS= read -r line || [ -n "$line" ]; do
  lineno=$((lineno + 1))
  line="${line%$'\r'}"
  case "$line" in
    "-- @"*)
      flush
      d="${line#-- @}"; d="$(printf '%s' "$d" | sed 's/[[:space:]]*$//')"
      case "$d" in
        A|B)            cur_kind="$d"; cur_line=$lineno ;;
        "A &"|"B &")    cur_kind="${d%% *}&"; cur_line=$lineno ;;
        "A wait"|"B wait") KINDS+=("${d%% *}wait"); BODIES+=(""); LINES+=("$lineno") ;;
        observe)        cur_kind="observe"; cur_line=$lineno ;;
        "expect "*)
          set -- $d
          if [ $# -ne 3 ] || { [ "$2" != A ] && [ "$2" != B ]; }; then
            fail2 "시나리오 ${lineno}행의 지시를 읽지 못했습니다: $line" "형식은 「-- @expect A ok」 또는 「-- @expect B 40P01」 입니다 (파일 머리 주석 참고)"
          fi
          case "$3" in ok|[0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z]) ;;
            *) fail2 "시나리오 ${lineno}행의 기대 값을 읽지 못했습니다: $3" "ok 또는 다섯 글자 오류 코드(SQLSTATE, 예: 40P01)를 적으세요" ;;
          esac
          EXPECT_S+=("$2"); EXPECT_V+=("$3") ;;
        *) fail2 "시나리오 ${lineno}행의 지시를 읽지 못했습니다: $line" "쓸 수 있는 지시는 -- @A, -- @B, -- @A &, -- @B &, -- @A wait, -- @B wait, -- @observe, -- @expect 입니다 (./sessions.sh 머리 주석)" ;;
      esac ;;
    *)
      if [ -n "$cur_kind" ]; then
        cur_body="$cur_body$line"$'\n'
      else
        bare="$(printf '%s' "$line" | sed 's/^[[:space:]]*//')"
        case "$bare" in ""|--*) ;;
          *) fail2 "시나리오 ${lineno}행이 어느 세션에 보낼 문장인지 정해지지 않았습니다: $line" "그 줄 위에 -- @A 나 -- @B 지시를 두세요" ;;
        esac
      fi ;;
  esac
done < "$FILE"
flush
[ ${#KINDS[@]} -gt 0 ] || fail2 "시나리오에 단계가 없습니다: $ARG" "-- @A / -- @B 지시 아래에 보낼 문장을 적으세요"

# 「&」로 보낸 세션에 wait 전에 다른 문장을 보내는 형식 오류를 미리 잡는다.
pa=0; pb=0; i=0
while [ $i -lt ${#KINDS[@]} ]; do
  k="${KINDS[$i]}"
  case "$k" in
    A|"A&") [ $pa = 0 ] || fail2 "시나리오 ${LINES[$i]}행: 세션 A 는 앞의 「-- @A &」 문장이 끝나기를 기다리는 중입니다" "그 앞에 -- @A wait 를 두세요"
            [ "$k" = "A&" ] && pa=1 ;;
    B|"B&") [ $pb = 0 ] || fail2 "시나리오 ${LINES[$i]}행: 세션 B 는 앞의 「-- @B &」 문장이 끝나기를 기다리는 중입니다" "그 앞에 -- @B wait 를 두세요"
            [ "$k" = "B&" ] && pb=1 ;;
    Await)  [ $pa = 1 ] || fail2 "시나리오 ${LINES[$i]}행: 기다릴 「-- @A &」 문장이 없습니다" "-- @A wait 는 -- @A & 뒤에만 씁니다"
            pa=0 ;;
    Bwait)  [ $pb = 1 ] || fail2 "시나리오 ${LINES[$i]}행: 기다릴 「-- @B &」 문장이 없습니다" "-- @B wait 는 -- @B & 뒤에만 씁니다"
            pb=0 ;;
  esac
  i=$((i + 1))
done

# ---------- 실행 전 점검과 잠금 ----------
kit_runtime_check "sessions" 2
kit_connect_check "sessions" 2
kit_lock_acquire   # world 를 바꾸므로 러너·다른 재현과 겹치지 않게

[ -f ./reset.sh ] && [ -x ./reset.sh ] || fail2 "kit 파일 reset.sh 을(를) 실행할 수 없습니다 (없거나 실행 권한이 없습니다)" "파일이 지워졌다면 kit을 다시 받으세요 (0장 0.3절). 파일은 있는데 권한이 없으면 chmod +x reset.sh 뒤 다시 실행하세요"
./reset.sh >/dev/null || fail2 "시작 전 world 초기화에 실패했습니다 (위 reset 메시지 참고)" "./reset.sh 를 직접 실행해 원인을 확인하세요"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/ll-sessions.XXXXXX")" || fail2 "임시 디렉토리를 만들 수 없습니다" "TMPDIR 의 권한을 확인하세요"
PID_A=""; PID_B=""; BG=""

# 세션 하나를 띄운다: 입력은 이름 붙인 파이프(fd 3 = A, fd 5 = B), 출력은 파일(A.out·B.out).
# psql 의 표준 출력과 오류는 psql 과 같은 쪽에서 합친다 — 기본 경로에서 호스트에서 합치면 docker 가 두
# 스트림을 따로 실어 날라 ERROR 줄과 표식 줄의 차례가 뒤바뀔 수 있다 (kit_psql.sh kit_psql_merged 주석).
open_session() { # $1=A|B
  local s="$1" n
  mkfifo "$WORK/$s.in" || fail2 "세션 $s 의 입력 파이프를 만들지 못했습니다" "TMPDIR 의 권한을 확인하세요"
  : > "$WORK/$s.out"
  kit_psql_merged -d "$DB" -v ON_ERROR_STOP=0 --pset pager=off < "$WORK/$s.in" >> "$WORK/$s.out" &
  BG="$BG $!"
  if [ "$s" = A ]; then exec 3>"$WORK/$s.in"; else exec 5>"$WORK/$s.in"; fi
  send_raw "$s" "SELECT pg_backend_pid() AS kit_pid \\gset
\\echo __PID__ :kit_pid
\\set ECHO queries"
  n=0
  while ! grep -q '^__PID__ ' "$WORK/$s.out" 2>/dev/null; do
    n=$((n + 1)); [ $n -le 150 ] || fail2 "세션 $s 를 열지 못했습니다 (15초 안에 응답 없음)" "./check_env.sh 로 접속을 확인하세요"
    sleep 0.1
  done
  if [ "$s" = A ]; then PID_A="$(sed -n 's/^__PID__ //p' "$WORK/$s.out" | head -1)"; else PID_B="$(sed -n 's/^__PID__ //p' "$WORK/$s.out" | head -1)"; fi
}

send_raw() { # $1=A|B, $2=보낼 내용
  if [ "$1" = A ]; then printf '%s\n' "$2" >&3; else printf '%s\n' "$2" >&5; fi
}

OFF_A=1; OFF_B=1   # 화면에 찍은 출력 줄 수 (첫 줄의 __PID__ 표식까지 건너뛴다)
SEQ_A=0; SEQ_B=0
STATES_A=""; STATES_B=""   # 단계마다의 오류 코드 (00000 = 오류 없음)
NOWAIT=""                  # 「&」인데 잠금을 기다리지 않은 단계

print_new() { # $1=A|B — 새로 나온 출력 줄을 [A] 접두로 찍는다 (표식 줄은 뺀다)
  local s="$1" off total
  if [ "$s" = A ]; then off=$OFF_A; else off=$OFF_B; fi
  total=$(wc -l < "$WORK/$s.out" | tr -d ' ')
  if [ "$total" -gt "$off" ]; then
    awk -v n="$off" -v p="[$s] " 'NR > n && $0 !~ /^__(DONE|PID)__ / { print p $0 }' "$WORK/$s.out"
  fi
  if [ "$s" = A ]; then OFF_A=$total; else OFF_B=$total; fi
}

wait_done() { # $1=A|B, $2=단계 번호, $3=시한(초) → 0 이면 표식이 나왔다
  local s="$1" k="$2" n=0 lim=$(( $3 * 10 ))
  while ! grep -q "^__DONE__ $k " "$WORK/$s.out" 2>/dev/null; do
    n=$((n + 1)); [ $n -le $lim ] || return 1
    sleep 0.1
  done
  return 0
}

record_state() { # $1=A|B, $2=단계 번호
  local st
  st="$(sed -n "s/^__DONE__ $2 //p" "$WORK/$1.out" | head -1)"
  if [ "$1" = A ]; then STATES_A="$STATES_A $st"; else STATES_B="$STATES_B $st"; fi
}

send_step() { # $1=A|B, $2=본문 → 단계 번호를 SEQ 에 올리고 보낸다
  local s="$1" body="$2" k
  if [ "$s" = A ]; then SEQ_A=$((SEQ_A + 1)); k=$SEQ_A; else SEQ_B=$((SEQ_B + 1)); k=$SEQ_B; fi
  send_raw "$s" "\\set LAST_ERROR_SQLSTATE 00000
$body
\\echo __DONE__ $k :LAST_ERROR_SQLSTATE"
}

describe() { # $1=머리, $2=본문 — 본문의 「--」 줄을 설명으로 찍는다
  local desc
  desc="$(printf '%s' "$2" | sed -n 's/^[[:space:]]*--[[:space:]]\{0,1\}//p' | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
  echo
  if [ -n "$desc" ]; then echo "── $1: $desc"; else echo "── $1"; fi
}

sql_only() { # 본문에서 설명 줄을 뺀 것
  printf '%s' "$1" | sed '/^[[:space:]]*--/d'
}

cleanup() {
  # 파일 기술자만 닫는다 — 오류 억제는 이 묶음에만 건다(exec 에 바로 붙이면 셸의 표준 오류가 영영 닫힌다).
  { exec 3>&- 5>&-; } 2>/dev/null
  if [ -n "$PID_A$PID_B" ]; then
    kit_psql -d "$KIT_ADMIN_DB" -tAc "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid IN (${PID_A:-0}, ${PID_B:-0})" >/dev/null 2>&1 || true
  fi
  # shellcheck disable=SC2086
  [ -z "$BG" ] || wait $BG 2>/dev/null
  rm -rf "$WORK"
}
trap 'cleanup; kit_lock_release' EXIT   # 잠금 해제 trap 을 덮어쓰므로 함께 부른다

echo "시나리오: $ARG"
echo "세션 A·B 를 열고 문장을 차례대로 보냅니다. [A]·[B] 줄은 그 세션의 psql 출력입니다 (보낸 문장도 함께 찍힙니다)."
open_session A
open_session B

i=0
while [ $i -lt ${#KINDS[@]} ]; do
  k="${KINDS[$i]}"; body="${BODIES[$i]}"
  case "$k" in
    A|B)
      describe "$k" "$body"
      send_step "$k" "$(sql_only "$body")"
      if [ "$k" = A ]; then n=$SEQ_A; else n=$SEQ_B; fi
      if ! wait_done "$k" "$n" 15; then
        print_new "$k"
        fail2 "세션 $k 의 응답을 15초 안에 받지 못했습니다 (시나리오 ${LINES[$i]}행 — 다른 세션의 잠금에 막혔을 수 있습니다)" \
              "잠금을 기다리게 하려던 문장이면 그 단계를 「-- @$k &」로 쓰고 뒤에 「-- @$k wait」를 두세요"
      fi
      print_new "$k"; record_state "$k" "$n" ;;
    "A&"|"B&")
      s="${k%&}"
      describe "$s (끝나기를 기다리지 않고 다음으로)" "$body"
      send_step "$s" "$(sql_only "$body")"
      if [ "$s" = A ]; then n=$SEQ_A; pid=$PID_A; else n=$SEQ_B; pid=$PID_B; fi
      waited=0; m=0
      while [ $m -le 100 ]; do
        if grep -q "^__DONE__ $n " "$WORK/$s.out" 2>/dev/null; then break; fi
        if [ "$(kit_psql -d "$DB" -tAc "SELECT wait_event_type FROM pg_stat_activity WHERE pid = $pid" 2>/dev/null)" = "Lock" ]; then
          waited=1; break
        fi
        m=$((m + 1)); sleep 0.1
      done
      print_new "$s"
      if [ $waited = 1 ]; then
        echo "[$s] (잠금을 기다리는 중 — 다른 세션이 끝나기를 기다립니다)"
        eval "PEND_$s=$n"
      elif grep -q "^__DONE__ $n " "$WORK/$s.out" 2>/dev/null; then
        echo "[$s] (잠금을 기다리지 않고 끝났습니다 — 이 단계는 잠금 대기를 재현하지 못했습니다)"
        record_state "$s" "$n"; NOWAIT="$NOWAIT ${LINES[$i]}행"
        eval "PEND_$s=done"
      else
        fail2 "세션 $s 의 문장이 10초 안에 끝나지도 잠금을 기다리지도 않았습니다 (시나리오 ${LINES[$i]}행)" \
              "그 문장이 잠금이 아닌 이유로 오래 걸리는지 확인하세요 — 「-- @$s &」는 잠금을 기다리게 될 문장에 씁니다"
      fi ;;
    Await|Bwait)
      s="${k%wait}"
      eval "p=\${PEND_$s:-}"
      echo; echo "── $s: 기다리던 문장의 결과"
      if [ "$p" != done ]; then
        if ! wait_done "$s" "$p" 15; then
          print_new "$s"
          fail2 "세션 $s 가 기다리던 문장이 15초 안에 끝나지 않았습니다 (시나리오 ${LINES[$i]}행)" \
                "그 문장을 막고 있는 다른 세션이 COMMIT·ROLLBACK 하는 단계가 이 wait 앞에 있는지 확인하세요"
        fi
        print_new "$s"; record_state "$s" "$p"
      fi
      eval "PEND_$s="
      ;;
    observe)
      describe "관찰 (세 번째 연결)" "$body"
      sql_only "$body" | kit_psql_merged -d "$DB" -q -v ON_ERROR_STOP=0 --pset pager=off | sed -e '/^$/d' -e 's/^/[관찰] /' ;;
  esac
  i=$((i + 1))
done

# 기다리던 문장이 남아 있으면 마저 받는다.
for s in A B; do
  eval "p=\${PEND_$s:-}"
  if [ -n "$p" ] && [ "$p" != done ]; then
    echo; echo "── $s: 기다리던 문장의 결과 (시나리오 끝)"
    wait_done "$s" "$p" 15 || true
    print_new "$s"; record_state "$s" "$p"
  fi
done

# ---------- 판정 ----------
echo
verdict=0; notes=""
if [ -n "$NOWAIT" ]; then verdict=1; notes="$notes 잠금을 기다리지 않은 「&」 단계:$NOWAIT;"; fi
j=0
while [ $j -lt ${#EXPECT_S[@]} ]; do
  s="${EXPECT_S[$j]}"; v="${EXPECT_V[$j]}"
  if [ "$s" = A ]; then st="$STATES_A"; else st="$STATES_B"; fi
  bad=""; hit=0
  for c in $st; do
    [ "$c" = 00000 ] || bad="$bad $c"
    [ "$c" = "$v" ] && hit=1
  done
  if [ "$v" = ok ]; then
    if [ -n "$bad" ]; then verdict=1; notes="$notes 세션 $s 에 오류가 났습니다(오류 코드:$bad);"; fi
  else
    if [ $hit = 0 ]; then verdict=1; notes="$notes 세션 $s 에서 오류 $v 가 나지 않았습니다(단계별 코드:${st:- 없음});"; fi
  fi
  j=$((j + 1))
done
if [ $verdict = 0 ]; then
  if [ ${#EXPECT_S[@]} -gt 0 ]; then
    echo "결과: 기대대로 재현되었습니다 — 단계별 오류 코드 A:${STATES_A:- 없음} / B:${STATES_B:- 없음}"
  else
    echo "결과: 끝까지 실행했습니다 (-- @expect 지시가 없어 오류 코드는 판정하지 않았습니다) — 단계별 오류 코드 A:${STATES_A:- 없음} / B:${STATES_B:- 없음}"
  fi
else
  echo "결과: 기대와 다름 —$notes"
fi

{ exec 3>&- 5>&-; } 2>/dev/null
if [ $KEEP = 1 ]; then
  echo "정리: --keep — world 를 되돌리지 않았습니다. 다 보셨으면 ./reset.sh 로 되돌리세요."
else
  cleanup; PID_A=""; PID_B=""; BG=""; WORK="$(mktemp -d "${TMPDIR:-/tmp}/ll-sessions.XXXXXX")"
  if ./reset.sh >/dev/null; then
    echo "정리: world 를 초기 상태로 되돌렸습니다."
  else
    echo "sessions 실패: 끝난 뒤 world 초기화에 실패했습니다 (위 reset 메시지 참고)" >&2
    echo "  다음: ./reset.sh 를 직접 실행해 원인을 확인하세요." >&2
    exit 2
  fi
fi
exit $verdict
