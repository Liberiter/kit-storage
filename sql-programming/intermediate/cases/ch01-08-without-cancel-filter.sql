-- 1장 1.1 «왜 그럴까요»: 취소를 빼지 않으면 매출이 부풀어 오른다
SELECT
    to_char(orders.order_date, 'YYYY-MM') AS 주문월,
    sum(order_items.unit_price * order_items.quantity) AS 매출,
    sum(order_items.quantity) AS 판매권수
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
GROUP BY to_char(orders.order_date, 'YYYY-MM')
ORDER BY 매출 DESC, 주문월;
