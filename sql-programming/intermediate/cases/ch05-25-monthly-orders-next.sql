-- 5장 5.2 «practice» 2: 2025년 월별 주문 건수에 다음 달 건수를 붙인다
WITH monthly_orders AS (
    SELECT
        to_char(order_date, 'YYYY-MM') AS 주문월,
        count(*) AS 주문건수
    FROM orders
    WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31'
        AND status <> '취소'
    GROUP BY to_char(order_date, 'YYYY-MM')
)
SELECT
    주문월,
    주문건수,
    lead(주문건수) OVER (ORDER BY 주문월) AS 다음달건수,
    lead(주문건수) OVER (ORDER BY 주문월) - 주문건수 AS 증감
FROM monthly_orders
ORDER BY 주문월;
