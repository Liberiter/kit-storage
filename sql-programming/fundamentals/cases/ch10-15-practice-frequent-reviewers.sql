-- 10.1 practice 2 풀이: 리뷰를 10건 이상 쓴 손님의 고객번호와 이름
SELECT customer_id AS 고객번호, name AS 이름
FROM customers
WHERE customer_id IN (
    SELECT customer_id FROM reviews GROUP BY customer_id HAVING count(*) >= 10
)
ORDER BY customer_id;
