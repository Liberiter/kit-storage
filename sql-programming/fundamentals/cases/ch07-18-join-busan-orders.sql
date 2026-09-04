-- 7.3 따라 하기 4단계: 두 번째 1:N 쌍 (customers ──< orders)
SELECT orders.order_id, customers.name, customers.city, orders.order_date
FROM orders
INNER JOIN customers ON orders.customer_id = customers.customer_id
WHERE customers.city = '부산'
ORDER BY orders.order_id
LIMIT 5;
