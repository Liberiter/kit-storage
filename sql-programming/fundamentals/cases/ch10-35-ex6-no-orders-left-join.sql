-- 복습 exercise 6 (8장) 해설 (가): 주문이 없는 손님을 LEFT JOIN + IS NULL로
SELECT customers.customer_id AS 고객번호
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE orders.order_id IS NULL
ORDER BY customers.customer_id
LIMIT 5;
