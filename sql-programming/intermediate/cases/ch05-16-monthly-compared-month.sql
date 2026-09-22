-- 5장 5.2 «따라 하기» 3단계: 셋째 인자로 견줄 행이 없을 때 낼 값을 정한다
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
    lag(주문월, 1, '(없음)') OVER (ORDER BY 주문월) AS "견준 달",
    매출 - lag(매출) OVER (ORDER BY 주문월) AS 증감
FROM monthly_sales
ORDER BY 주문월;
