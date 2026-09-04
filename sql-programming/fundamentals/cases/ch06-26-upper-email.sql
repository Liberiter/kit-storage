-- 6.3 따라 하기 3단계: upper로 글자를 대문자로 바꾼다
SELECT customer_id, email, upper(email) AS "대문자 이메일"
FROM customers
ORDER BY customer_id
LIMIT 3;
