-- 7.1 따라 하기 2단계: 기본키 값으로 고르면 언제나 한 행이다
SELECT customer_id, name, city, signup_date
FROM customers
WHERE customer_id = 12;
