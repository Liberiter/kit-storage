-- 5.1 practice 1 풀이 — 생일을 적지 않은 고객
SELECT customer_id, name, signup_date
FROM customers
WHERE birth_date IS NULL
ORDER BY customer_id
LIMIT 5;
