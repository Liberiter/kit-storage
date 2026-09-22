-- 5장 5.2 «따라 하기» 4단계: 둘째 인자로 열두 칸 앞 — 작년 같은 달과 견준다
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
with_last_year AS (
    SELECT
        주문월,
        매출,
        lag(매출, 12) OVER (ORDER BY 주문월) AS 작년매출
    FROM monthly_sales
)
SELECT 주문월, 매출, 작년매출, 매출 - 작년매출 AS 증감
FROM with_last_year
WHERE 주문월 >= '2026-01'
ORDER BY 주문월;
