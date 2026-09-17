-- 2장 2.1 «따라 하기» 4단계 — 조인 조건을 바꿔 같은 부서 동료를 짝짓는다
SELECT
    s.name AS 직원,
    c.name AS 동료
FROM staff AS s
INNER JOIN staff AS c
    ON s.department = c.department
    AND s.staff_id <> c.staff_id
WHERE s.department = '경영'
ORDER BY s.staff_id, c.staff_id;
