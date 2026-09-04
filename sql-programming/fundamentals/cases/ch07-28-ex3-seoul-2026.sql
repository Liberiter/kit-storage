-- exercise 3 해설: 서울 고객이 2026년에 낸 주문 (3장 BETWEEN, 두 줄로 나눈 WHERE)
SELECT orders.order_id, customers.name, orders.order_date, orders.status
FROM orders
INNER JOIN customers ON orders.customer_id = customers.customer_id
WHERE customers.city = '서울'
    AND orders.order_date BETWEEN '2026-01-01' AND '2026-12-31'
ORDER BY orders.order_date, orders.order_id
LIMIT 5;
