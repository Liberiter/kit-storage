-- 1장 1.1 «흔한 실수»: 조인한 결과의 행 수는 주문 수가 아니다
SELECT count(*) AS 주문항목수
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
    AND orders.status <> '취소';

SELECT count(*) AS 주문수
FROM orders
WHERE order_date BETWEEN '2026-01-01' AND '2026-06-30'
    AND status <> '취소';
