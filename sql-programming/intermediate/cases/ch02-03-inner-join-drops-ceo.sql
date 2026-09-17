-- 2장 2.1 «따라 하기» 2단계 — 전체 직원 수와 상사를 붙인 줄 수를 견준다
SELECT count(*) AS 직원수 FROM staff;

SELECT count(*) AS "상사를 붙인 줄 수"
FROM staff AS s
INNER JOIN staff AS m ON s.manager_id = m.staff_id;
