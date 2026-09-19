-- 3장 3.2 «따라 하기» 5단계: 조인 조건의 좌우를 바꿔 위로 거슬러 오른다
WITH RECURSIVE chain AS (
    SELECT staff_id, name, manager_id, 1 AS 단계
    FROM staff
    WHERE staff_id = 23
    UNION ALL
    SELECT staff.staff_id, staff.name, staff.manager_id, chain.단계 + 1
    FROM staff
    INNER JOIN chain ON staff.staff_id = chain.manager_id
)
SELECT 단계, staff_id AS 직원번호, name AS 이름
FROM chain
ORDER BY 단계;
