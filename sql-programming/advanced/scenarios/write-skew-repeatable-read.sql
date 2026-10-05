-- 시나리오: 쓰기 치우침 — scenarios/serialization-failure.sql 과 같은 차례를 REPEATABLE READ 로 돌린다.
-- 두 트랜잭션이 모두 커밋되어 1번 지점의 당직이 0명이 된다. 오류는 나지 않는다.
-- 실행: ./sessions.sh scenarios/write-skew-repeatable-read.sql

-- @A
-- A가 REPEATABLE READ 트랜잭션을 열고 1번 지점의 당직 수를 셉니다 (2명).
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT count(*) AS on_duty FROM duty_roster WHERE store_id = 1 AND on_duty;

-- @B
-- B도 같은 수를 셉니다 (2명).
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT count(*) AS on_duty FROM duty_roster WHERE store_id = 1 AND on_duty;

-- @A
-- A가 14번 직원의 당직을 끕니다.
UPDATE duty_roster SET on_duty = false WHERE store_id = 1 AND staff_id = 14;

-- @B
-- B가 15번 직원의 당직을 끕니다. 서로 다른 행이라 잠금으로 부딪히지 않습니다.
UPDATE duty_roster SET on_duty = false WHERE store_id = 1 AND staff_id = 15;

-- @A
COMMIT;

-- @B
COMMIT;

-- @observe
-- 남은 당직 수 — 규칙이 깨졌습니다.
SELECT count(*) AS on_duty FROM duty_roster WHERE store_id = 1 AND on_duty;

-- @expect A ok
-- @expect B ok
