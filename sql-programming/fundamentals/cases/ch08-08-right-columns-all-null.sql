-- 8.1 왜 그럴까요: 짝이 없으면 오른쪽 테이블의 모든 열이 널이 된다
-- (orders.status는 널을 허용하지 않는 열인데도 널이다. LIMIT을 떼면 29행)
SELECT customers.customer_id, customers.name, orders.status
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE orders.status IS NULL
ORDER BY customers.customer_id
LIMIT 5;
