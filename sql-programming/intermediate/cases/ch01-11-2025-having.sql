-- 1장 1.1 «practice» 2: 기간을 2025년으로 바꾸고 묶은 뒤 그룹을 거른다
SELECT
    to_char(orders.order_date, 'YYYY-MM') AS 주문월,
    sum(order_items.unit_price * order_items.quantity) AS 매출
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.order_date BETWEEN '2025-01-01' AND '2025-12-31'
    AND orders.status <> '취소'
GROUP BY to_char(orders.order_date, 'YYYY-MM')
HAVING sum(order_items.unit_price * order_items.quantity) >= 1300000
ORDER BY 매출 DESC, 주문월;
