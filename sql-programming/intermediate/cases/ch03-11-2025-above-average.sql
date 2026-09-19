-- 3장 3.1 «practice» 2: 2025년 달 가운데 매출이 평균 이상인 달
WITH monthly_items AS (
    SELECT
        to_char(orders.order_date, 'YYYY-MM') AS 주문월,
        order_items.unit_price * order_items.quantity AS 금액
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.order_date BETWEEN '2025-01-01' AND '2025-12-31'
        AND orders.status <> '취소'
),
monthly_sales AS (
    SELECT 주문월, sum(금액) AS 매출
    FROM monthly_items
    GROUP BY 주문월
)
SELECT 주문월, 매출
FROM monthly_sales
WHERE 매출 >= (SELECT avg(매출) FROM monthly_sales)
ORDER BY 주문월;
