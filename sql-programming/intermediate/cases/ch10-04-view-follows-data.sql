-- runner: reset
-- 10장 10.1 «따라 하기» 3단계: 5월 주문 하나를 취소로 바꾸면 뷰의 5월 매출이 따라 바뀐다
CREATE VIEW monthly_sales AS
SELECT
    to_char(orders.order_date, 'YYYY-MM') AS sales_month,
    count(DISTINCT orders.order_id) AS order_count,
    sum(order_items.unit_price * order_items.quantity) AS revenue,
    sum(order_items.quantity) AS units_sold
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.status <> '취소'
GROUP BY to_char(orders.order_date, 'YYYY-MM');

SELECT sales_month, order_count, revenue
FROM monthly_sales
WHERE sales_month = '2026-05';

UPDATE orders SET status = '취소' WHERE order_id = 240;

SELECT sales_month, order_count, revenue
FROM monthly_sales
WHERE sales_month = '2026-05';
