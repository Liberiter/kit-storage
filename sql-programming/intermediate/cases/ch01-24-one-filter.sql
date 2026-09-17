-- 1장 1.3 «따라 하기» 1단계: 집계 함수 하나에만 조건을 붙인다
SELECT
    to_char(order_date, 'YYYY-MM') AS 주문월,
    count(*) AS 전체,
    count(*) FILTER (WHERE status = '배송완료') AS 배송완료
FROM orders
WHERE order_date BETWEEN '2026-01-01' AND '2026-06-30'
GROUP BY to_char(order_date, 'YYYY-MM')
ORDER BY 주문월;
