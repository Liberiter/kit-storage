-- 1장 «연습하기» exercise 4: 달마다 매출과 취소된 주문에 담겼던 금액
SELECT
    to_char(orders.order_date, 'YYYY-MM') AS 주문월,
    sum(order_items.unit_price * order_items.quantity)
        FILTER (WHERE orders.status <> '취소') AS 매출,
    sum(order_items.unit_price * order_items.quantity)
        FILTER (WHERE orders.status = '취소') AS 취소금액
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
GROUP BY to_char(orders.order_date, 'YYYY-MM')
ORDER BY 주문월;
