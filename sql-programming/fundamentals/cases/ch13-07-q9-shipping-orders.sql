-- 13장 exit assessment 문항 9 해설: 7월 이후 들어온 배송중 주문과 그 손님
SELECT
    orders.order_id AS 주문번호,
    customers.name AS 손님,
    customers.city AS 도시,
    orders.order_date AS 주문일
FROM orders
INNER JOIN customers ON orders.customer_id = customers.customer_id
WHERE orders.status = '배송중' AND orders.order_date >= '2026-07-01'
ORDER BY orders.order_date, orders.order_id;
