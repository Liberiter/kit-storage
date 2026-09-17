-- 1장 «도전하기» problem 3: 취소가 잦은 손님
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 이름,
    count(*) AS 주문수,
    count(*) FILTER (WHERE orders.status = '취소') AS 취소수
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_id, customers.name
HAVING count(*) FILTER (WHERE orders.status = '취소') >= 3
ORDER BY 취소수 DESC, 고객번호;
