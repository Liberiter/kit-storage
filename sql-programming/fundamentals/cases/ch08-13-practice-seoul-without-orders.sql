-- 8.1 practice 2 풀이: 서울에 사는 고객 중 주문이 없는 사람
SELECT customers.customer_id, customers.name, customers.signup_date
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE customers.city = '서울' AND orders.order_id IS NULL
ORDER BY customers.customer_id;
