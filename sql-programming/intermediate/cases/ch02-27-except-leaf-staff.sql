-- 2장 2.3 «따라 하기» 5단계 — 같은 질문을 EXCEPT 로 물으면 널에 걸리지 않는다
SELECT staff_id AS 직원번호
FROM staff
EXCEPT
SELECT manager_id
FROM staff
ORDER BY 직원번호;
