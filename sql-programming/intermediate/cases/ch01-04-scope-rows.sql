-- 1장 1.1 «따라 하기» 3단계: 묶기 전에 행을 좁히고 몇 줄인지 센다
SELECT count(*) AS 주문항목수
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
    AND orders.status <> '취소';
