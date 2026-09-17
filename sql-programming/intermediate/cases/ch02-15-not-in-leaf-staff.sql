-- 2장 2.2 «따라 하기» 3단계 — NOT IN 으로 물으면 0행이 나온다 (함정)
SELECT staff.staff_id AS 직원번호, staff.name AS 이름
FROM staff
WHERE staff.staff_id NOT IN (SELECT manager_id FROM staff)
ORDER BY staff.staff_id;
