-- 9.2 따라 하기 4단계: 조인한 결과를 그룹으로 묶는다 (주문이 많은 손님 다섯)
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 이름,
    count(*) AS 주문수
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_id, customers.name
ORDER BY 주문수 DESC, 고객번호
LIMIT 5;
