-- 9.2 practice 2 풀이: 주문 상태별 건수
SELECT status AS 상태, count(*) AS 주문수
FROM orders
GROUP BY status
ORDER BY 주문수 DESC;
