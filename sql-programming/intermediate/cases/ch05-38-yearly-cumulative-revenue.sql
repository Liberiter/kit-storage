-- 5장 «연습하기» exercise 3 해설: 해마다 다시 시작하는 누적 매출
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
    sum(매출) OVER (PARTITION BY 연도 ORDER BY 주문월) AS "연 누적"
FROM monthly_sales
ORDER BY 주문월;
