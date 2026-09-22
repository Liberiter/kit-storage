-- 5장 5.2 «왜 그럴까요»: lag 가 가리키는 것은 「한 달 전」이 아니라 「앞 행」이다
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
    lag(주문월) OVER (ORDER BY 주문월) AS "앞 행의 달"
FROM monthly_sales
WHERE 주문월 <> '2026-03'
ORDER BY 주문월;
