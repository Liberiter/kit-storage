-- 시나리오: 고유 제약 검사의 대기 — 같은 값을 넣는 두 번째 세션은 첫 세션이 끝날 때까지 기다렸다가,
-- 첫 세션이 커밋하면 고유 위반(23505)으로 끝난다. (첫 세션이 되돌리면 두 번째 세션의 행이 들어간다.)
-- 실행: ./sessions.sh scenarios/unique-insert-wait.sql
-- 재료: accounts.email 의 고유 제약.

-- @A
-- A가 새 회원을 넣고 트랜잭션을 열어 둡니다.
BEGIN;
INSERT INTO accounts (account_id, email, name, city, district, birth_year, grade, joined_at, marketing_opt_in)
VALUES (300001, 'new.reader@bookmail.kr', '새독자', '서울', '마포구', 1995, '일반', '2026-09-01 10:00:00+09', false);

-- @B
-- B도 트랜잭션을 엽니다.
BEGIN;

-- @B &
-- B가 같은 이메일로 다른 회원을 넣으려 합니다. 고유 검사가 A의 결말을 알 때까지 기다립니다.
INSERT INTO accounts (account_id, email, name, city, district, birth_year, grade, joined_at, marketing_opt_in)
VALUES (300002, 'new.reader@bookmail.kr', '새독자', '서울', '송파구', 1996, '일반', '2026-09-01 10:05:00+09', false);

-- @observe
-- 기다리는 쪽은 A의 트랜잭션 번호(transactionid)를 기다립니다.
SELECT l.locktype, l.mode, l.granted
  FROM pg_locks l JOIN pg_stat_activity a USING (pid)
 WHERE a.datname = current_database() AND a.pid <> pg_backend_pid() AND l.locktype = 'transactionid'
 ORDER BY l.granted;

-- @A
-- A가 커밋합니다. 이제 B의 고유 검사가 결말을 냅니다.
COMMIT;

-- @B wait

-- @B
-- 오류로 끝난 B의 트랜잭션을 정리합니다.
ROLLBACK;

-- @expect A ok
-- @expect B 23505
