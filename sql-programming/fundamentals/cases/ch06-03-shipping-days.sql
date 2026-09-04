-- 6.1 따라 하기 2단계: 날짜 타입의 뺄셈 (발송까지 걸린 날수)
SELECT order_id, order_date, shipped_date, shipped_date - order_date AS 소요일
FROM orders
WHERE shipped_date IS NOT NULL
ORDER BY order_id
LIMIT 5;
