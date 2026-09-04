-- 10.2 왜 그럴까요: 짝이 되는 열의 타입이 맞지 않으면 오류 (exit 3)
SELECT customer_id AS 고객번호
FROM orders
UNION
SELECT name
FROM customers;
