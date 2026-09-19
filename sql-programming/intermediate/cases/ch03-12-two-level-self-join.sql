-- 3장 3.2 «문제 상황»: 셀프 조인은 조인 수만큼의 단계까지만 훑는다
SELECT name AS 부하
FROM staff
WHERE manager_id = 3
ORDER BY staff_id;

SELECT s1.name AS "1단계 부하", s2.name AS "2단계 부하"
FROM staff AS s1
INNER JOIN staff AS s2 ON s2.manager_id = s1.staff_id
WHERE s1.manager_id = 3
ORDER BY s1.staff_id, s2.staff_id;
