-- exercise 2 해설: 리뷰를 많이 쓴 손님 다섯
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 이름,
    count(*) AS 리뷰수
FROM customers
INNER JOIN reviews ON customers.customer_id = reviews.customer_id
GROUP BY customers.customer_id, customers.name
ORDER BY 리뷰수 DESC, 고객번호
LIMIT 5;
