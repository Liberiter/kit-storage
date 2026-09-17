-- 2장 2.2 «따라 하기» 6단계 — NOT IN 을 고치려면 서브쿼리에서 널을 먼저 뺀다
-- (ch02-17 과 기대 출력이 바이트 동일하다)
SELECT s.staff_id AS 직원번호, s.name AS 이름, s.department AS 부서
FROM staff AS s
WHERE s.staff_id NOT IN (
    SELECT manager_id FROM staff WHERE manager_id IS NOT NULL
)
ORDER BY s.staff_id;
