-- 7.1 왜 그럴까요: email도 유일하다 (UNIQUE 제약) — 그래도 기본키는 아니다
SELECT customer_id, name, city
FROM customers
WHERE email = 'yeonwoo.choi2@bookmail.kr';
