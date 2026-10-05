-- 시나리오: 데드락 — 두 세션이 서로 상대가 잠근 행을 기다리는 고리를 만든다.
-- 실행: ./sessions.sh scenarios/deadlock.sql
-- 기대: 먼저 기다리기 시작한 A 가 deadlock_timeout(기본 1초) 뒤 데드락을 찾아 자기 문장을 오류(40P01)로
-- 끝내고, B 는 A 가 놓은 잠금을 얻어 끝난다. 오류의 DETAIL 줄에는 실행마다 다른 프로세스·트랜잭션 번호가 찍힌다.

-- @A
-- A가 트랜잭션을 열고 1번 책의 재고를 고칩니다 — 1번 책의 행을 잠급니다.
BEGIN;
UPDATE books SET stock = stock - 1 WHERE book_id = 1;

-- @B
-- B가 트랜잭션을 열고 2번 책의 재고를 고칩니다 — 2번 책의 행을 잠급니다.
BEGIN;
UPDATE books SET stock = stock - 1 WHERE book_id = 2;

-- @A &
-- A가 2번 책을 고치려 합니다. B가 잠근 행이라 기다립니다.
UPDATE books SET stock = stock - 1 WHERE book_id = 2;

-- @observe
-- 지금 잠금을 기다리는 세션을 봅니다.
SELECT wait_event_type, wait_event, state, left(query, 50) AS query
  FROM pg_stat_activity
 WHERE datname = current_database() AND wait_event_type = 'Lock';

-- @B
-- B가 1번 책을 고치려 합니다. A가 잠근 행입니다 — 서로를 기다리는 고리가 생깁니다.
UPDATE books SET stock = stock - 1 WHERE book_id = 1;

-- @A wait

-- @A
-- 오류로 끝난 A의 트랜잭션을 정리합니다.
ROLLBACK;

-- @B
COMMIT;

-- @expect A 40P01
-- @expect B ok
