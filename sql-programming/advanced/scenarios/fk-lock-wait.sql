-- 시나리오: 외래키 검사가 잡는 잠금 — 부모 행을 지우는 트랜잭션이 끝날 때까지, 그 행을 참조하는 행을
-- 넣으려는 세션이 기다린다.
-- 실행: ./sessions.sh scenarios/fk-lock-wait.sql
-- 재료: 299999번 회원은 판매도 토론 글도 없다. sales.account_id 에는 인덱스가 없다(처음 상태) — 그래서 A 의
-- DELETE 는 외래키 검사로 sales 를 통째로 훑는다. 인덱스가 있을 때와 없을 때 이 DELETE 가 걸리는 시간은
-- ./measure.sh 로 견줄 수 있다.

-- @A
-- A가 트랜잭션을 열고 299999번 회원을 지웁니다. 그 회원의 행에 잠금이 걸리고, 외래키 검사가 sales를 훑습니다.
BEGIN;
DELETE FROM accounts WHERE account_id = 299999;

-- @B
-- B도 트랜잭션을 엽니다.
BEGIN;

-- @B &
-- B가 299999번 회원의 판매를 넣으려 합니다. 외래키 검사가 회원 행을 확인하려다 A의 잠금에 막혀 기다립니다.
INSERT INTO sales (sale_id, sold_at, account_id, book_id, store_id, channel, quantity, unit_price, status, receipt_no)
VALUES (1500001, '2026-08-31 23:00:00+09', 299999, 1, 1, 'web', 1, 15000, 'completed', 'R260831-1500001');

-- @observe
-- 기다리는 쪽(granted = f)과 그 잠금의 종류를 봅니다.
SELECT a.state, l.locktype, l.mode, l.granted, left(a.query, 40) AS query
  FROM pg_locks l JOIN pg_stat_activity a USING (pid)
 WHERE a.datname = current_database() AND a.pid <> pg_backend_pid()
   AND l.locktype IN ('transactionid', 'tuple')
 ORDER BY l.granted, l.locktype, l.mode;

-- @A
-- A가 지우기를 되돌립니다. 이제 B의 외래키 검사가 회원 행을 확인할 수 있습니다.
ROLLBACK;

-- @B wait

-- @B
-- B의 판매 넣기도 되돌립니다.
ROLLBACK;

-- @expect A ok
-- @expect B ok
