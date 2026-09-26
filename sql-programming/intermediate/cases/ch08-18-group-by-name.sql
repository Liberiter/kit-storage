-- 8장 8.2 «따라 하기» 6단계: 이름으로 묶으면 동명이인이 한 사람이 된다
SELECT customers.name AS 고객명, count(*) AS 주문수
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.name
ORDER BY 주문수 DESC, 고객명
LIMIT 3;

SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 고객명,
    count(*) AS 주문수
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_id, customers.name
ORDER BY 주문수 DESC, 고객번호
LIMIT 3;
