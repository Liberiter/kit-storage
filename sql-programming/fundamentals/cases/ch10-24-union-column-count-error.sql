-- 10.2 왜 그럴까요: 두 질의의 열 개수가 다르면 오류 (exit 3)
SELECT customer_id AS 고객번호
FROM orders
UNION
SELECT customer_id, name
FROM customers;
