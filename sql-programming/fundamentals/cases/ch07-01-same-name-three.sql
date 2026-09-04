-- 7.1 문제 상황: 이름 '최연우'로는 한 사람을 집을 수 없다 (동명이인 3명)
SELECT customer_id, name, city, email
FROM customers
WHERE name = '최연우'
ORDER BY customer_id;
