-- 2장 2.1 «흔한 실수» — 조인 조건의 좌우를 뒤집으면 부하가 상사 자리에 온다
SELECT
    s.name AS 직원,
    m.name AS 상사
FROM staff AS s
INNER JOIN staff AS m ON s.staff_id = m.manager_id
WHERE s.department = '물류'
ORDER BY s.staff_id;
