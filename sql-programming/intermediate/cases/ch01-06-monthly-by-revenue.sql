-- 1장 1.1 «따라 하기» 5단계: 요구가 말한 차례(매출이 큰 달부터)로 세운다
SELECT
    to_char(orders.order_date, 'YYYY-MM') AS 주문월,
    sum(order_items.unit_price * order_items.quantity) AS 매출,
    sum(order_items.quantity) AS 판매권수
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
    AND orders.status <> '취소'
GROUP BY to_char(orders.order_date, 'YYYY-MM')
ORDER BY 매출 DESC, 주문월;
