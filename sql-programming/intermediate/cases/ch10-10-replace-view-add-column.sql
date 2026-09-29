-- runner: reset
-- 10장 10.1 «practice» 2: CREATE OR REPLACE VIEW 로 끝에 열을 하나 더한다
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

CREATE OR REPLACE VIEW monthly_sales AS
SELECT
    to_char(orders.order_date, 'YYYY-MM') AS sales_month,
    count(DISTINCT orders.order_id) AS order_count,
    sum(order_items.unit_price * order_items.quantity) AS revenue,
    sum(order_items.quantity) AS units_sold,
    count(DISTINCT orders.customer_id) AS customer_count
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.status <> '취소'
GROUP BY to_char(orders.order_date, 'YYYY-MM');

SELECT sales_month, order_count, customer_count
FROM monthly_sales
WHERE sales_month LIKE '2026-%'
ORDER BY sales_month;
