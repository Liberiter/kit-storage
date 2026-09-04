-- 10.1 흔한 실수: NOT IN의 서브쿼리에 널이 섞이면 한 행도 남지 않는다
SELECT order_id AS 주문번호, order_date AS 주문일
FROM orders
WHERE order_id NOT IN (SELECT order_id FROM reviews)
ORDER BY order_id
LIMIT 5;
