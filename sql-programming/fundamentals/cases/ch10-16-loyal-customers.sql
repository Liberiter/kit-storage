-- 10.2 문제 상황: 주문을 20건 이상 한 단골 명단
SELECT customer_id AS 고객번호
FROM orders
GROUP BY customer_id
HAVING count(*) >= 20
ORDER BY 고객번호;
