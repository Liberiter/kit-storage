-- 9.3 흔한 실수: HAVING에는 별칭을 쓸 수 없다 (오류 기대, exit 3)
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 이름,
    count(*) AS 주문수
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_id, customers.name
HAVING 주문수 >= 20
ORDER BY 주문수 DESC, 고객번호;
