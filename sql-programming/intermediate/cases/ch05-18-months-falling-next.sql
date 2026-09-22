-- 5장 5.2 «따라 하기» 5단계: lead 로 다음 달을 보고, 줄어드는 달만 남긴다
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
with_next AS (
    SELECT
        주문월,
        매출,
        lead(매출) OVER (ORDER BY 주문월) AS 다음달매출
    FROM monthly_sales
)
SELECT 주문월, 매출, 다음달매출, 다음달매출 - 매출 AS 증감
FROM with_next
WHERE 다음달매출 < 매출
ORDER BY 주문월;
