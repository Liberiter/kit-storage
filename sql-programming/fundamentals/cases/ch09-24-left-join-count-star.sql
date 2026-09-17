-- 9.2 흔한 실수: LEFT JOIN 뒤에 count(*)를 쓰면 주문 없는 손님이 1로 세어진다
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 이름,
    count(*) AS 주문수
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE customers.customer_id BETWEEN 6 AND 9
GROUP BY customers.customer_id, customers.name
ORDER BY 고객번호;
