-- problem 1 해설: 단골이면서 리뷰어인 손님의 이름 (INTERSECT를 IN의 오른쪽에)
SELECT customer_id AS 고객번호, name AS 이름
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING count(*) >= 20
    INTERSECT
    SELECT customer_id
    FROM reviews
    GROUP BY customer_id
    HAVING count(*) >= 10
)
ORDER BY customer_id;
