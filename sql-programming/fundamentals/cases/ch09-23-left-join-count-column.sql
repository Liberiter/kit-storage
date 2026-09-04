-- 9.2 흔한 실수: count(오른쪽 테이블의 열)로 고치면 0이 된다
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 이름,
    count(orders.order_id) AS 주문수
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE customers.customer_id BETWEEN 6 AND 9
GROUP BY customers.customer_id, customers.name
ORDER BY 고객번호;
