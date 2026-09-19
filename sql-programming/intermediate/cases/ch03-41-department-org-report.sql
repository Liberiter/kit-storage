-- 3장 «도전하기» problem 1 해설: 부서별 조직 요약
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
),
leaf_staff AS (
    SELECT s.staff_id
    FROM staff AS s
    WHERE NOT EXISTS (SELECT 1 FROM staff AS x WHERE x.manager_id = s.staff_id)
)
SELECT
    org.department AS 부서,
    count(*) AS 인원,
    max(org.단계) AS "가장 깊은 단계",
    count(*) FILTER (WHERE org.staff_id IN (SELECT staff_id FROM leaf_staff))
        AS "부하 없는 사람"
FROM org
GROUP BY org.department
ORDER BY "가장 깊은 단계" DESC, 부서;
