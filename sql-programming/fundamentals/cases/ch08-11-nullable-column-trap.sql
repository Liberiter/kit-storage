-- 8.1 흔한 실수: 널을 허용하는 열로 IS NULL을 걸면 짝이 있는 행까지 섞인다
-- (orders.shipped_date는 발송 전이면 널이다. LIMIT을 떼면 173행)
SELECT
    customers.customer_id,
    customers.name,
    orders.order_id,
    orders.shipped_date
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE orders.shipped_date IS NULL
ORDER BY customers.customer_id, orders.order_id
LIMIT 5;
