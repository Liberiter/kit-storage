-- 3장 3.1 «문제 상황»: 집계의 집계를 HAVING 에 적으면 오류다
SELECT
    to_char(orders.order_date, 'YYYY-MM') AS 주문월,
    sum(order_items.quantity) AS 판매권수
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
    AND orders.status <> '취소'
GROUP BY to_char(orders.order_date, 'YYYY-MM')
HAVING sum(order_items.quantity) >= avg(sum(order_items.quantity))
ORDER BY 주문월;
