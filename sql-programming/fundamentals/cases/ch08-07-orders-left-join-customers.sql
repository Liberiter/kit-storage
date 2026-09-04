-- 8.1 왜 그럴까요: 왼쪽과 오른쪽을 바꾸면 남는 것이 달라진다
-- (주문에는 고객이 반드시 있으므로 LIMIT을 떼면 620행 — 내부 조인과 같다)
SELECT orders.order_id, orders.order_date, customers.name
FROM orders
LEFT JOIN customers ON orders.customer_id = customers.customer_id
ORDER BY orders.order_id
LIMIT 5;
