-- 2장 2.1 «흔한 실수» — 자기 자신을 빼지 않으면 자기가 동료로 나온다
SELECT
    s.name AS 직원,
    c.name AS 동료
FROM staff AS s
INNER JOIN staff AS c ON s.department = c.department
WHERE s.department = '경영'
ORDER BY s.staff_id, c.staff_id;
