-- 1장 1.3 «문제 상황»: 달과 상태로 묶으면 표가 세로로 길어진다
SELECT
    to_char(order_date, 'YYYY-MM') AS 주문월,
    status AS 상태,
    count(*) AS 주문수
FROM orders
WHERE order_date BETWEEN '2026-01-01' AND '2026-06-30'
GROUP BY to_char(order_date, 'YYYY-MM'), status
ORDER BY 주문월, 상태
LIMIT 8;
