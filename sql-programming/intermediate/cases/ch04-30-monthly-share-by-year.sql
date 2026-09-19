-- 4장 4.3 «따라 하기» 4단계: 달마다의 매출이 그 해에서 차지하는 비중
WITH paid_items AS (
    SELECT
        orders.order_date AS 주문일,
        order_items.unit_price * order_items.quantity AS 금액
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.order_date >= '2025-01-01'
        AND orders.status <> '취소'
),
monthly_sales AS (
    SELECT
        to_char(주문일, 'YYYY') AS 연도,
        to_char(주문일, 'YYYY-MM') AS 주문월,
        sum(금액) AS 매출
    FROM paid_items
    GROUP BY to_char(주문일, 'YYYY'), to_char(주문일, 'YYYY-MM')
)
SELECT
    주문월,
    매출,
    round(100.0 * 매출 / sum(매출) OVER (PARTITION BY 연도), 1) AS "비중(%)"
FROM monthly_sales
ORDER BY 주문월;
