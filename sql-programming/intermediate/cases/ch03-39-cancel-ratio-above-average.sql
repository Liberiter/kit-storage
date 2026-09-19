-- 3장 «복습 exercise» 1 해설 (1장 조건 집계): 취소율이 평균 이상인 달
WITH monthly_status AS (
    SELECT
        to_char(order_date, 'YYYY-MM') AS 주문월,
        count(*) AS 주문수,
        count(*) FILTER (WHERE status = '취소') AS 취소수
    FROM orders
    WHERE order_date BETWEEN '2026-01-01' AND '2026-06-30'
    GROUP BY to_char(order_date, 'YYYY-MM')
),
monthly_ratio AS (
    SELECT
        주문월,
        주문수,
        취소수,
        round(100.0 * 취소수 / 주문수, 1) AS "취소율(%)"
    FROM monthly_status
)
SELECT 주문월, 주문수, 취소수, "취소율(%)"
FROM monthly_ratio
WHERE "취소율(%)" >= (SELECT avg("취소율(%)") FROM monthly_ratio)
ORDER BY 주문월;
