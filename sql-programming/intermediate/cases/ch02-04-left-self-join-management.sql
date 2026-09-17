-- 2장 2.1 «따라 하기» 3단계 — LEFT JOIN 으로 상사가 없는 대표까지 남긴다
SELECT
    s.name AS 직원,
    s.title AS 직급,
    m.name AS 상사
FROM staff AS s
LEFT JOIN staff AS m ON s.manager_id = m.staff_id
WHERE s.department = '경영'
ORDER BY s.staff_id;
