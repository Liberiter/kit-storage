-- 5장 5.2 «왜 그럴까요»: 창의 차례를 바꾸면 「직전」이 가리키는 행도 바뀐다
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
    lag(주문월) OVER (ORDER BY 매출 DESC) AS "바로 위 달",
    lag(매출) OVER (ORDER BY 매출 DESC) AS "바로 위 매출"
FROM monthly_sales
ORDER BY 매출 DESC;
