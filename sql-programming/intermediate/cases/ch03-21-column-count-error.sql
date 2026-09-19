-- 3장 3.2 «흔한 실수»: 시작 질의와 재귀 질의의 열 수가 다르면 오류다
WITH RECURSIVE org AS (
    SELECT staff_id, name, 1 AS 단계
    FROM staff
    WHERE manager_id IS NULL
    UNION ALL
    SELECT staff.staff_id, staff.name
    FROM staff
    INNER JOIN org ON staff.manager_id = org.staff_id
)
SELECT count(*) AS 인원 FROM org;
