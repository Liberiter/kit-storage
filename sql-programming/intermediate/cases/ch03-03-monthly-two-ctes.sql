-- 3장 3.1 «따라 하기» 2단계: CTE 둘을 이어 정의한다
WITH monthly_items AS (
    SELECT
        to_char(orders.order_date, 'YYYY-MM') AS 주문월,
        order_items.unit_price * order_items.quantity AS 금액,
        order_items.quantity AS 권수
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
        AND orders.status <> '취소'
),
monthly_sales AS (
    SELECT 주문월, sum(금액) AS 매출, sum(권수) AS 판매권수
    FROM monthly_items
    GROUP BY 주문월
)
SELECT 주문월, 매출, 판매권수
FROM monthly_sales
ORDER BY 판매권수 DESC, 주문월;
