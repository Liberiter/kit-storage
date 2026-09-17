-- 2장 2.1 «따라 하기» 1단계 — 같은 테이블을 두 번 읽어 직원에게 상사 이름을
-- 붙인다
SELECT
    s.name AS 직원,
    s.title AS 직급,
    m.name AS 상사
FROM staff AS s
INNER JOIN staff AS m ON s.manager_id = m.staff_id
WHERE s.department = '물류'
ORDER BY s.staff_id;
