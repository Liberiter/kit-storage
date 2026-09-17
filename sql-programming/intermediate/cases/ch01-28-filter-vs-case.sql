-- 1장 1.3 «따라 하기» 5단계: 같은 셈을 CASE 표기로도 적어 본다
SELECT
    to_char(order_date, 'YYYY-MM') AS 주문월,
    count(*) FILTER (WHERE status = '취소') AS "FILTER 표기",
    sum(CASE WHEN status = '취소' THEN 1 ELSE 0 END) AS "CASE 표기"
FROM orders
WHERE order_date BETWEEN '2026-01-01' AND '2026-06-30'
GROUP BY to_char(order_date, 'YYYY-MM')
ORDER BY 주문월;
