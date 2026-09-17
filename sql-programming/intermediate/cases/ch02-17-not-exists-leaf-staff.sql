-- 2장 2.2 «따라 하기» 5단계 — NOT EXISTS 로 부하가 없는 직원을 뽑는다
SELECT s.staff_id AS 직원번호, s.name AS 이름, s.department AS 부서
FROM staff AS s
WHERE NOT EXISTS (SELECT 1 FROM staff AS x WHERE x.manager_id = s.staff_id)
ORDER BY s.staff_id;
