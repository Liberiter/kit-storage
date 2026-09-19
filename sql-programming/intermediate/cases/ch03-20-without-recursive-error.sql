-- 3장 3.2 «흔한 실수»: RECURSIVE 를 빠뜨리면 CTE 가 자기 이름을 부르지 못한다
WITH org AS (
    SELECT staff_id, name, 1 AS 단계
    FROM staff
    WHERE manager_id IS NULL
    UNION ALL
    SELECT staff.staff_id, staff.name, org.단계 + 1
    FROM staff
    INNER JOIN org ON staff.manager_id = org.staff_id
)
SELECT count(*) AS 인원 FROM org;
