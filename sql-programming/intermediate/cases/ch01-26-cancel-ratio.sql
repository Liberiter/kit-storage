-- 1장 1.3 «따라 하기» 3단계: 조건 집계로 비율을 낸다
SELECT
    to_char(order_date, 'YYYY-MM') AS 주문월,
    count(*) AS 전체,
    count(*) FILTER (WHERE status = '취소') AS 취소,
    round(100.0 * count(*) FILTER (WHERE status = '취소') / count(*), 1)
        AS "취소율(%)"
FROM orders
WHERE order_date BETWEEN '2026-01-01' AND '2026-06-30'
GROUP BY to_char(order_date, 'YYYY-MM')
ORDER BY "취소율(%)" DESC, 주문월;
