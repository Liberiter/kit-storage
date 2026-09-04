-- 8.1 문제 상황: 내부 조인으로 주문을 붙이면 7번 조유나가 사라진다 (7장 조인)
SELECT customers.customer_id, customers.name, orders.order_id, orders.order_date
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
WHERE customers.customer_id BETWEEN 6 AND 9
ORDER BY customers.customer_id, orders.order_id;
