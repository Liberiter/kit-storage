-- problem 1 해설: 주문이 하나도 없는 손님을 가입일 오래된 순으로 (LIMIT을 떼면 29행)
SELECT customers.customer_id, customers.name, customers.signup_date
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE orders.order_id IS NULL
ORDER BY customers.signup_date, customers.customer_id
LIMIT 5;
