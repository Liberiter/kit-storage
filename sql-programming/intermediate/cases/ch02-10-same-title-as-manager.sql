-- 2장 2.1 «practice» 2 — 상사와 직급이 같은 직원
SELECT
    s.name AS 직원,
    s.title AS 직급,
    m.name AS 상사,
    m.title AS "상사 직급"
FROM staff AS s
INNER JOIN staff AS m ON s.manager_id = m.staff_id
WHERE s.title = m.title
ORDER BY s.staff_id;
