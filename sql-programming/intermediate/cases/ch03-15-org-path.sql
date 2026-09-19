-- 3장 3.2 «따라 하기» 3단계: 보고선을 글자로 이어 붙인다
WITH RECURSIVE org AS (
    SELECT staff_id, name, 1 AS 단계, name AS 보고선
    FROM staff
    WHERE manager_id IS NULL
    UNION ALL
    SELECT
        staff.staff_id,
        staff.name,
        org.단계 + 1,
        org.보고선 || ' > ' || staff.name
    FROM staff
    INNER JOIN org ON staff.manager_id = org.staff_id
)
SELECT 단계, 보고선
FROM org
ORDER BY 보고선;
