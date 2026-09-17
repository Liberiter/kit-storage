-- 1장 1.1 «따라 하기» 6단계: 달별 합이 전체 합과 맞는지 대조한다
SELECT
    sum(order_items.unit_price * order_items.quantity) AS 매출합계,
    sum(order_items.quantity) AS 판매권수합계
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
    AND orders.status <> '취소';
