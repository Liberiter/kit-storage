-- runner: reset
-- 10장 10.1 «따라 하기» 4단계: 뷰 위에서 5장의 lag 로 전월 대비를 낸다
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

SELECT
    sales_month AS 주문월,
    revenue AS 매출,
    revenue - lag(revenue) OVER (ORDER BY sales_month) AS 전월대비
FROM monthly_sales
WHERE sales_month LIKE '2026-%'
ORDER BY sales_month;
