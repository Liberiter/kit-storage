-- 10장 10.1 «문제 상황»: 3장처럼 CTE로 달마다 매출을 다시 적어 7·8월을 본다
WITH monthly_sales AS (
    SELECT
        to_char(orders.order_date, 'YYYY-MM') AS 주문월,
        sum(order_items.unit_price * order_items.quantity) AS 매출,
        sum(order_items.quantity) AS 판매권수
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.status <> '취소'
    GROUP BY to_char(orders.order_date, 'YYYY-MM')
)
SELECT 주문월, 매출, 판매권수
FROM monthly_sales
WHERE 주문월 IN ('2026-07', '2026-08')
ORDER BY 주문월;
