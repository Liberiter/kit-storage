-- runner: reset
-- 10장 10.1 «왜 그럴까요»: 결과를 표에 복사해 두면 주문이 취소되어도 그대로 남는다
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

CREATE TABLE monthly_sales_copy (
    sales_month text PRIMARY KEY,
    revenue bigint NOT NULL
);

INSERT INTO monthly_sales_copy (sales_month, revenue)
SELECT sales_month, revenue
FROM monthly_sales;

UPDATE orders SET status = '취소' WHERE order_id = 240;

SELECT
    monthly_sales.sales_month,
    monthly_sales.revenue AS 뷰의매출,
    monthly_sales_copy.revenue AS 복사본의매출
FROM monthly_sales
INNER JOIN monthly_sales_copy
    ON monthly_sales.sales_month = monthly_sales_copy.sales_month
WHERE monthly_sales.sales_month = '2026-05';
