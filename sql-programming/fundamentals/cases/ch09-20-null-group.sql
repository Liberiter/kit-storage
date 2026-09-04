-- 9.2 왜 그럴까요: 그룹 키가 널인 행들은 하나의 그룹으로 모인다 (5장·8장)
SELECT orders.status AS 상태, count(*) AS 줄수
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY orders.status
ORDER BY 상태;
