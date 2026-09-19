-- 3장 «복습 exercise» 2 해설 (2장 반조인): 부하가 없는 직원을 단계와 함께
WITH RECURSIVE org AS (
    SELECT staff_id, name, 1 AS 단계
    FROM staff
    WHERE manager_id IS NULL
    UNION ALL
    SELECT staff.staff_id, staff.name, org.단계 + 1
    FROM staff
    INNER JOIN org ON staff.manager_id = org.staff_id
)
SELECT org.단계, org.staff_id AS 직원번호, org.name AS 이름
FROM org
WHERE NOT EXISTS (
    SELECT 1 FROM staff WHERE staff.manager_id = org.staff_id
)
ORDER BY org.단계, org.staff_id;
