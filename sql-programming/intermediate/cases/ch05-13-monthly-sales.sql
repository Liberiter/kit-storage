-- 5장 5.2 «문제 상황»: 스무 달의 매출 — 옆 칸에 지난달 값이 없다
WITH monthly_sales AS (
    SELECT
        to_char(orders.order_date, 'YYYY-MM') AS 주문월,
        sum(order_items.unit_price * order_items.quantity) AS 매출
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.order_date >= '2025-01-01'
        AND orders.status <> '취소'
    GROUP BY to_char(orders.order_date, 'YYYY-MM')
)
SELECT 주문월, 매출
FROM monthly_sales
ORDER BY 주문월;
