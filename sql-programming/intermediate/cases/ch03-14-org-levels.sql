-- 3장 3.2 «따라 하기» 2단계: 재귀 항을 붙여 조직 전체를 단계와 함께 펼친다
WITH RECURSIVE org AS (
    SELECT staff_id, name, title, 1 AS 단계
    FROM staff
    WHERE manager_id IS NULL
    UNION ALL
    SELECT staff.staff_id, staff.name, staff.title, org.단계 + 1
    FROM staff
    INNER JOIN org ON staff.manager_id = org.staff_id
)
SELECT 단계, staff_id AS 직원번호, name AS 이름, title AS 직급
FROM org
ORDER BY 단계, staff_id;
