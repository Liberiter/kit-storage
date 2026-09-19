-- 3장 «연습하기» exercise 2 해설: 부서마다 인원과 가장 깊은 단계
WITH RECURSIVE org AS (
    SELECT staff_id, name, department, 1 AS 단계
    FROM staff
    WHERE manager_id IS NULL
    UNION ALL
    SELECT
        staff.staff_id,
        staff.name,
        staff.department,
        org.단계 + 1
    FROM staff
    INNER JOIN org ON staff.manager_id = org.staff_id
)
SELECT department AS 부서, count(*) AS 인원, max(단계) AS "가장 깊은 단계"
FROM org
GROUP BY department
ORDER BY "가장 깊은 단계" DESC, 부서;
