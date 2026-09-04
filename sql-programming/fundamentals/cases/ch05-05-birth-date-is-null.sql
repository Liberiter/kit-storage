-- 5.1 따라 하기 3단계 — customers.birth_date의 NULL (선택 입력 미기재)
SELECT customer_id, name, city, birth_date
FROM customers
WHERE birth_date IS NULL
ORDER BY customer_id
LIMIT 5;
