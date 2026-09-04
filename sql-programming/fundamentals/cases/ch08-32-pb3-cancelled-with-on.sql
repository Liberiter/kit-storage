-- problem 3 (b) 해설: 취소 조건을 ON으로 옮기면 취소 주문이 없는 손님도 남는다
SELECT customers.customer_id, customers.name, orders.order_id, orders.order_date
FROM customers
LEFT JOIN orders
    ON customers.customer_id = orders.customer_id
    AND orders.status = '취소'
WHERE customers.customer_id BETWEEN 1 AND 8
ORDER BY customers.customer_id, orders.order_id;
