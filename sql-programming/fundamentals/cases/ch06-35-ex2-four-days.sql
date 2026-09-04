-- exercise 2 해설: 발송까지 나흘 걸린 주문 중 가장 최근 다섯 건
SELECT order_id, order_date, shipped_date, shipped_date - order_date AS 소요일
FROM orders
WHERE shipped_date - order_date = 4
ORDER BY order_date DESC, order_id
LIMIT 5;
