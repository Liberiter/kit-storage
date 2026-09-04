-- problem 2 해설: 리뷰는 썼지만 주문은 한 번도 없는 손님 (EXCEPT를 IN의 오른쪽에)
SELECT customer_id AS 고객번호, name AS 이름, city AS 도시
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM reviews
    EXCEPT
    SELECT customer_id
    FROM orders
)
ORDER BY customer_id
LIMIT 5;
