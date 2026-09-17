-- 9.3 문제 상황: 집계 조건을 WHERE에 적으면 오류 (오류 기대, exit 3)
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 이름,
    count(*) AS 주문수
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
WHERE count(*) >= 20
GROUP BY customers.customer_id, customers.name
ORDER BY 주문수 DESC, 고객번호;
