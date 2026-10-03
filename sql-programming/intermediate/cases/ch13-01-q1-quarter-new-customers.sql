-- 13장(exit assessment) 문항 1 해설: 2025년 분기별 주문 고객·신규 고객·신규 비중·전 분기 대비 증감
WITH first_order AS (
    SELECT customer_id, min(order_date) AS 첫주문일
    FROM orders
    WHERE status <> '취소'
    GROUP BY customer_id
),
order_quarter AS (
    SELECT
        orders.customer_id,
        orders.order_date,
        first_order.첫주문일,
        CASE
            WHEN orders.order_date < '2025-04-01' THEN '1분기'
            WHEN orders.order_date < '2025-07-01' THEN '2분기'
            WHEN orders.order_date < '2025-10-01' THEN '3분기'
            ELSE '4분기'
        END AS 분기
    FROM orders
    INNER JOIN first_order ON orders.customer_id = first_order.customer_id
    WHERE orders.status <> '취소'
        AND orders.order_date BETWEEN '2025-01-01' AND '2025-12-31'
),
quarter_stat AS (
    SELECT
        분기,
        count(DISTINCT customer_id) AS 주문고객,
        count(DISTINCT customer_id) FILTER (WHERE order_date = 첫주문일)
            AS 신규고객
    FROM order_quarter
    GROUP BY 분기
)
SELECT
    분기,
    주문고객,
    신규고객,
    round(100.0 * 신규고객 / 주문고객, 1) AS "신규 비중(%)",
    주문고객 - lag(주문고객) OVER (ORDER BY 분기) AS 전분기대비
FROM quarter_stat
ORDER BY 분기;
