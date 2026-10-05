-- 시나리오: 행 잠금의 강도 — 키가 아닌 열을 고치는 UPDATE 는 외래키 검사와 부딪히지 않고, 키 열을 고치는
-- UPDATE 는 부딪힌다.
-- 실행: ./sessions.sh scenarios/key-share-no-wait.sql
-- 재료: 299998번 회원은 판매가 없다.

-- @A
-- A가 299998번 회원의 등급(키가 아닌 열)을 고치고 트랜잭션을 열어 둡니다.
BEGIN;
UPDATE accounts SET grade = '골드' WHERE account_id = 299998;

-- @B
-- B가 그 회원의 판매를 넣습니다. 외래키 검사가 회원 행에 거는 잠금은 A의 잠금과 부딪히지 않아 기다리지 않습니다.
BEGIN;
INSERT INTO sales (sale_id, sold_at, account_id, book_id, store_id, channel, quantity, unit_price, status, receipt_no)
VALUES (1500001, '2026-08-31 23:00:00+09', 299998, 1, 1, 'web', 1, 15000, 'completed', 'R260831-1500001');

-- @observe
-- 두 세션 모두 트랜잭션을 연 채 기다리지 않고 있습니다 (wait_event_type 이 비어 있습니다).
SELECT a.state, a.wait_event_type, left(a.query, 60) AS query
  FROM pg_stat_activity a
 WHERE a.datname = current_database() AND a.pid <> pg_backend_pid() AND a.backend_type = 'client backend'
 ORDER BY a.query;

-- @A &
-- A가 이번에는 회원 번호(키 열)를 고치려 합니다. B가 그 행에 건 잠금과 부딪혀 기다립니다.
UPDATE accounts SET account_id = 900000 WHERE account_id = 299998;

-- @B
-- B가 판매 넣기를 되돌립니다.
ROLLBACK;

-- @A wait

-- @A
ROLLBACK;

-- @expect A ok
-- @expect B ok
