-- 3장 3.2 «따라 하기» 1단계: 재귀의 출발점이 될 시작 질의
SELECT staff_id AS 직원번호, name AS 이름, title AS 직급, 1 AS 단계
FROM staff
WHERE manager_id IS NULL;
