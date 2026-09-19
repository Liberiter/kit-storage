-- 4장 4.2 «practice» 1: 월별 매출과 여섯 달 평균의 차이
WITH monthly_sales AS (
    SELECT
        to_char(orders.order_date, 'YYYY-MM') AS 주문월,
        sum(order_items.unit_price * order_items.quantity) AS 매출
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
        AND orders.status <> '취소'
    GROUP BY to_char(orders.order_date, 'YYYY-MM')
)
SELECT
    주문월,
    매출,
    round(avg(매출) OVER ()) AS "여섯 달 평균",
    매출 - round(avg(매출) OVER ()) AS 차이
FROM monthly_sales
ORDER BY 주문월;
