-- runner: reset
-- 10장 «연습하기» exercise 2 해설: 배송 소요일 함수로 2026년 달마다 평균 소요일
CREATE FUNCTION delivery_days(ordered date, shipped date)
RETURNS integer
LANGUAGE sql
AS $$
SELECT shipped - ordered AS 소요일;
$$;

SELECT
    to_char(order_date, 'YYYY-MM') AS 주문월,
    count(*) AS 주문수,
    count(delivery_days(order_date, shipped_date)) AS 발송수,
    round(avg(delivery_days(order_date, shipped_date)), 1) AS 평균소요일
FROM orders
WHERE order_date >= '2026-01-01'
GROUP BY to_char(order_date, 'YYYY-MM')
ORDER BY 주문월;
