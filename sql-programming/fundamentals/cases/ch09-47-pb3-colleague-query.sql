-- problem 3 (a): 동료가 쓴 질의. LEFT JOIN 뒤에 count(*)를 써서
-- 리뷰가 없는 손님도 1건으로 세어진다
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 이름,
    count(*) AS 리뷰수
FROM customers
LEFT JOIN reviews ON customers.customer_id = reviews.customer_id
WHERE customers.customer_id BETWEEN 1 AND 8
GROUP BY customers.customer_id, customers.name
ORDER BY 고객번호;
