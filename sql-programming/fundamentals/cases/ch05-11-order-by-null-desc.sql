-- 5.1 왜 그럴까요 — 내림차순 정렬에서 NULL은 맨 앞에 놓인다 (같은 6건)
SELECT order_id, status, shipped_date
FROM orders
WHERE customer_id = 4
ORDER BY shipped_date DESC, order_id;
