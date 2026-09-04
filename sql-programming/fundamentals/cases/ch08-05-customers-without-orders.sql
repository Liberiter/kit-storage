-- 8.1 따라 하기 3단계: 짝이 없는 행만 고른다 (주문 없는 고객, LIMIT을 떼면 29행)
SELECT customers.customer_id, customers.name, customers.city, orders.order_id
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE orders.order_id IS NULL
ORDER BY customers.customer_id
LIMIT 5;
