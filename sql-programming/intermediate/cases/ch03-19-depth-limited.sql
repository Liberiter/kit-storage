-- 3장 3.2 «왜 그럴까요»: 재귀 항이 새 행을 내지 못하면 되풀이가 멈춘다
WITH RECURSIVE org AS (
    SELECT staff_id, name, 1 AS 단계
    FROM staff
    WHERE manager_id IS NULL
    UNION ALL
    SELECT staff.staff_id, staff.name, org.단계 + 1
    FROM staff
    INNER JOIN org ON staff.manager_id = org.staff_id
    WHERE org.단계 < 2
)
SELECT 단계, count(*) AS 인원
FROM org
GROUP BY 단계
ORDER BY 단계;
