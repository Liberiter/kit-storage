-- 8.1 흔한 실수: 같은 조건을 ON으로 옮기면 짝짓기 기준이 되어 왼쪽 행이 남는다
SELECT customers.customer_id, customers.name, orders.order_id, orders.status
FROM customers
LEFT JOIN orders
    ON customers.customer_id = orders.customer_id
    AND orders.status = '배송완료'
WHERE customers.customer_id BETWEEN 6 AND 9
ORDER BY customers.customer_id, orders.order_id;
