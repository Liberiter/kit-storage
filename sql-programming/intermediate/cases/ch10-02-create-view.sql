-- runner: reset
-- 10장 10.1 «따라 하기» 1단계: 뷰 monthly_sales 를 만들고 표처럼 부른다
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

SELECT sales_month, order_count, revenue, units_sold
FROM monthly_sales
WHERE sales_month LIKE '2026-%'
ORDER BY sales_month;
