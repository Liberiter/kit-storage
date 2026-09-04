-- 5.1 왜 그럴까요 — 오름차순 정렬에서 NULL은 맨 뒤에 놓인다 (고객 4의 주문 6건)
SELECT order_id, status, shipped_date
FROM orders
WHERE customer_id = 4
ORDER BY shipped_date, order_id;
