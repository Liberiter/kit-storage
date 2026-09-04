-- exercise 2 해설: 취소한 주문이 있는 손님 (IN 서브쿼리)
SELECT customer_id AS 고객번호, name AS 이름
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders WHERE status = '취소')
ORDER BY customer_id
LIMIT 5;
