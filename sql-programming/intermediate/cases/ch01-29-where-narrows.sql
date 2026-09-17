-- 1장 1.3 «왜 그럴까요»: WHERE 로 좁히면 분모로 쓸 행까지 사라진다
SELECT
    to_char(order_date, 'YYYY-MM') AS 주문월,
    count(*) AS 주문수
FROM orders
WHERE order_date BETWEEN '2026-01-01' AND '2026-06-30'
    AND status = '취소'
GROUP BY to_char(order_date, 'YYYY-MM')
ORDER BY 주문월;
