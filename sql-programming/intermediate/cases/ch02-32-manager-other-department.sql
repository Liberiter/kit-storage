-- 2장 «연습하기» exercise 1 해설 — 상사가 다른 부서에 있는 직원
SELECT
    s.name AS 직원,
    s.department AS 부서,
    m.name AS 상사,
    m.department AS "상사 부서"
FROM staff AS s
INNER JOIN staff AS m ON s.manager_id = m.staff_id
WHERE s.department <> m.department
ORDER BY s.staff_id;
