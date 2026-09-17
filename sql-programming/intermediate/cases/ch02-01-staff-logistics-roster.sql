-- 2장 2.1 «문제 상황» — 물류 부서 직원 명부에는 상사의 «번호»만 있다
SELECT staff_id AS 직원번호, name AS 이름, manager_id AS 상사번호
FROM staff
WHERE department = '물류'
ORDER BY staff_id;
