-- 5장 5.2 «따라 하기» 2단계: 증감과 증감률을 낸다 (창의 값에 이름을 붙여 한 겹)
WITH monthly_sales AS (
    SELECT
        to_char(orders.order_date, 'YYYY-MM') AS 주문월,
        sum(order_items.unit_price * order_items.quantity) AS 매출
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.order_date >= '2025-01-01'
        AND orders.status <> '취소'
    GROUP BY to_char(orders.order_date, 'YYYY-MM')
),
with_prev AS (
    SELECT 주문월, 매출, lag(매출) OVER (ORDER BY 주문월) AS 전월매출
    FROM monthly_sales
)
SELECT
    주문월,
    매출,
    전월매출,
    매출 - 전월매출 AS 증감,
    round(100.0 * (매출 - 전월매출) / 전월매출, 1) AS "증감률(%)"
FROM with_prev
ORDER BY 주문월;
