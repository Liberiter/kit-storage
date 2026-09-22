-- 5장 5.3 «practice» 1: 월별 매출의 석 달 이동 평균
WITH monthly_sales AS (
    SELECT
        to_char(orders.order_date, 'YYYY-MM') AS 주문월,
        sum(order_items.unit_price * order_items.quantity) AS 매출
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.order_date >= '2025-01-01'
        AND orders.status <> '취소'
    GROUP BY to_char(orders.order_date, 'YYYY-MM')
)
SELECT
    주문월,
    매출,
    round(avg(매출) OVER (
        ORDER BY 주문월
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    )) AS "석 달 평균"
FROM monthly_sales
ORDER BY 주문월;
