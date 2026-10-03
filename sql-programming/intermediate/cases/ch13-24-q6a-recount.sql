-- 13장(exit assessment) 문항 6 (가) 해설: 다른 길로 센 8월 주문 수와 매출 (도시별 합계와 맞춰 보기)
SELECT
    count(DISTINCT orders.order_id) AS 주문수,
    sum(order_items.quantity * order_items.unit_price) AS 매출
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.status <> '취소'
    AND orders.order_date BETWEEN '2026-08-01' AND '2026-08-31';
