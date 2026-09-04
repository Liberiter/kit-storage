-- 8.1 문제 상황: 고객 6~9번은 네 명이다 (7번 조유나가 명단에 있다)
SELECT customer_id, name, city, signup_date
FROM customers
WHERE customer_id BETWEEN 6 AND 9
ORDER BY customer_id;
