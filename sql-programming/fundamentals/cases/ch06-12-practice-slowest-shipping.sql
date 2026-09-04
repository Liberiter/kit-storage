-- 6.1 practice 2 풀이: 발송까지 가장 오래 걸린 주문 다섯 건
SELECT order_id, order_date, shipped_date, shipped_date - order_date AS 소요일
FROM orders
WHERE shipped_date IS NOT NULL
ORDER BY 소요일 DESC, order_id
LIMIT 5;
