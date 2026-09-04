-- 6.1 왜 그럴까요: 날짜 + 정수는 날짜다
SELECT order_id, order_date, order_date + 3 AS "사흘 뒤"
FROM orders
ORDER BY order_id
LIMIT 3;
