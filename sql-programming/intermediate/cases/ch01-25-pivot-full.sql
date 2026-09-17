-- 1장 1.3 «따라 하기» 2단계: 네 상태를 한 줄에 나란히 놓는다
SELECT
    to_char(order_date, 'YYYY-MM') AS 주문월,
    count(*) AS 전체,
    count(*) FILTER (WHERE status = '배송완료') AS 배송완료,
    count(*) FILTER (WHERE status = '배송중') AS 배송중,
    count(*) FILTER (WHERE status = '배송준비') AS 배송준비,
    count(*) FILTER (WHERE status = '취소') AS 취소
FROM orders
WHERE order_date BETWEEN '2026-01-01' AND '2026-06-30'
GROUP BY to_char(order_date, 'YYYY-MM')
ORDER BY 주문월;
