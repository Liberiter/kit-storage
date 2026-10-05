-- 시나리오: SERIALIZABLE 의 직렬화 실패 — 「1번 지점에는 적어도 한 명이 당직」이라는 규칙을 두 세션이
-- 각자 지키는 줄 알고 함께 어긴다(쓰기 치우침). SERIALIZABLE 은 나중에 커밋하는 쪽을 오류(40001)로 끝낸다.
-- 실행: ./sessions.sh scenarios/serialization-failure.sql
-- 같은 차례를 REPEATABLE READ 로 돌리면 둘 다 커밋된다 — scenarios/write-skew-repeatable-read.sql

-- @A
-- A가 SERIALIZABLE 트랜잭션을 열고 1번 지점의 당직 수를 셉니다 (2명).
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT count(*) AS on_duty FROM duty_roster WHERE store_id = 1 AND on_duty;

-- @B
-- B도 같은 수를 셉니다 (2명).
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT count(*) AS on_duty FROM duty_roster WHERE store_id = 1 AND on_duty;

-- @A
-- 둘이니 한 명은 빠져도 된다고 보고, A가 14번 직원의 당직을 끕니다.
UPDATE duty_roster SET on_duty = false WHERE store_id = 1 AND staff_id = 14;

-- @B
-- B도 같은 판단으로 15번 직원의 당직을 끕니다.
UPDATE duty_roster SET on_duty = false WHERE store_id = 1 AND staff_id = 15;

-- @A
COMMIT;

-- @B
-- B가 커밋하려 합니다. 두 트랜잭션을 어느 차례로 한 번씩 돌려도 이 결과는 나올 수 없어, 오류로 끝납니다.
COMMIT;

-- @observe
-- 남은 당직 수.
SELECT count(*) AS on_duty FROM duty_roster WHERE store_id = 1 AND on_duty;

-- @expect A ok
-- @expect B 40001
