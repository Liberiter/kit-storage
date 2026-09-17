-- 2장 2.1 «practice» 1 — 고객지원 부서의 직원과 상사 (상사가 없어도 남긴다)
SELECT
    s.name AS 직원,
    s.title AS 직급,
    m.name AS 상사
FROM staff AS s
LEFT JOIN staff AS m ON s.manager_id = m.staff_id
WHERE s.department = '고객지원'
ORDER BY s.staff_id;
