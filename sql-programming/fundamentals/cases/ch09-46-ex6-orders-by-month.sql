-- 복습 exercise (6장) 해설: 2026년 5월 이후 월별 주문 수와 평균 발송 소요일
SELECT
    to_char(order_date, 'YYYY-MM') AS 주문월,
    count(*) AS 주문수,
    round(avg(shipped_date - order_date), 2) AS 평균소요일
FROM orders
WHERE order_date >= '2026-05-01'
GROUP BY to_char(order_date, 'YYYY-MM')
ORDER BY 주문월;
