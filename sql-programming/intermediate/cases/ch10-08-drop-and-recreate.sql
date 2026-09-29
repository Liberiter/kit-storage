-- runner: reset
-- 10장 10.1 «흔한 실수»: DROP VIEW 로 지우고 새 이름으로 다시 만든다
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

DROP VIEW monthly_sales;

CREATE VIEW monthly_sales AS
SELECT
    to_char(orders.order_date, 'YYYY-MM') AS sales_month,
    count(DISTINCT orders.order_id) AS order_count,
    sum(order_items.unit_price * order_items.quantity) AS net_revenue,
    sum(order_items.quantity) AS units_sold
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.status <> '취소'
GROUP BY to_char(orders.order_date, 'YYYY-MM');

SELECT sales_month, net_revenue
FROM monthly_sales
WHERE sales_month = '2026-05';
