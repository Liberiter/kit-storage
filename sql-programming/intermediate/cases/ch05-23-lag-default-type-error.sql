-- 5장 5.2 «흔한 실수»: 셋째 인자의 타입이 값과 맞지 않으면 오류 (오류 기대)
WITH monthly_sales AS (
    SELECT
        to_char(orders.order_date, 'YYYY-MM') AS 주문월,
        sum(order_items.unit_price * order_items.quantity) AS 매출
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.order_date >= '2026-01-01'
        AND orders.status <> '취소'
    GROUP BY to_char(orders.order_date, 'YYYY-MM')
)
SELECT
    주문월,
    매출,
    lag(매출, 1, '없음') OVER (ORDER BY 주문월) AS 전월매출
FROM monthly_sales
ORDER BY 주문월;
