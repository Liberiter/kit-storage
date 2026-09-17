-- problem 3 (b) 해설: count(reviews.review_id)로 고치면 0이 나온다
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 이름,
    count(reviews.review_id) AS 리뷰수
FROM customers
LEFT JOIN reviews ON customers.customer_id = reviews.customer_id
WHERE customers.customer_id BETWEEN 1 AND 8
GROUP BY customers.customer_id, customers.name
ORDER BY 고객번호;
