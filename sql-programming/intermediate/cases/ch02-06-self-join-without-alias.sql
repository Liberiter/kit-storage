-- 2장 2.1 «왜 그럴까요» — 별칭 없이 같은 테이블을 두 번 적으면 오류다
SELECT staff.name AS 직원, staff.name AS 상사
FROM staff
INNER JOIN staff ON staff.manager_id = staff.staff_id;
