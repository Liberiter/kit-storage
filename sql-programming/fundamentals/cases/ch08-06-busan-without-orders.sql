-- 8.1 따라 하기 4단계: 왼쪽 테이블의 조건과 함께 쓴다 (부산 + 주문 없음)
SELECT customers.customer_id, customers.name, customers.signup_date
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE customers.city = '부산' AND orders.order_id IS NULL
ORDER BY customers.customer_id;
