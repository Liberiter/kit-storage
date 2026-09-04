-- 8.1 따라 하기 2단계: 널로 채워진 자리를 5장의 COALESCE로 메운다
SELECT
    customers.customer_id,
    customers.name,
    COALESCE(orders.status, '주문 없음') AS 상태
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE customers.customer_id BETWEEN 6 AND 9
ORDER BY customers.customer_id, orders.order_id;
