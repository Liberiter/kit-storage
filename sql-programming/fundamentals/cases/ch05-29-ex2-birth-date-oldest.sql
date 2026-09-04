-- exercise 2 해설 — 생일을 적은 고객 중 생일이 가장 이른 다섯 명
SELECT customer_id, name, birth_date
FROM customers
WHERE birth_date IS NOT NULL
ORDER BY birth_date, customer_id
LIMIT 5;
