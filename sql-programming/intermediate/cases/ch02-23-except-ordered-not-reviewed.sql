-- 2장 2.3 «문제 상황» — 집합 연산으로 낸 명단에는 고객번호만 있다
SELECT customer_id AS 고객번호
FROM orders
EXCEPT
SELECT customer_id
FROM reviews
ORDER BY 고객번호;
