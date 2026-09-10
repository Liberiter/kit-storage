-- smoke: NULL 이 든 NOT IN 은 빈 결과, NOT EXISTS 는 부하 없는 직원을 찾는다 (2장 요구 예시)
SELECT count(*) AS leaf_staff_not_in
FROM staff
WHERE staff_id NOT IN (SELECT manager_id FROM staff);

SELECT count(*) AS leaf_staff_not_exists
FROM staff s
WHERE NOT EXISTS (SELECT 1 FROM staff x WHERE x.manager_id = s.staff_id);

SELECT s.name AS staff, m.name AS manager
FROM staff s
LEFT JOIN staff m ON m.staff_id = s.manager_id
WHERE s.department = '물류'
ORDER BY s.staff_id;
