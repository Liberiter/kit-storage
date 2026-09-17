-- 1장 1.1 «따라 하기» 2단계: 한 줄에 필요한 값을 모두 모은다
SELECT
    orders.order_id AS 주문번호,
    orders.order_date AS 주문일,
    orders.status AS 상태,
    order_items.quantity AS 수량,
    order_items.unit_price * order_items.quantity AS 금액
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
ORDER BY orders.order_id, order_items.book_id
LIMIT 5;
