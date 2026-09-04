-- 10.1 흔한 실수: 서브쿼리 쪽에서 널을 먼저 걸러 내면 제대로 나온다
SELECT order_id AS 주문번호, order_date AS 주문일
FROM orders
WHERE order_id NOT IN (SELECT order_id FROM reviews WHERE order_id IS NOT NULL)
ORDER BY order_id
LIMIT 5;
