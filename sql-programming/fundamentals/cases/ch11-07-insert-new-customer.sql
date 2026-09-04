-- runner: reset
-- 11.1 따라 하기 3단계 — 널을 허용하는 열은 적지 않아도 된다
INSERT INTO customers (name, email, city, signup_date, marketing_opt_in)
VALUES ('한지우', 'jiwoo.han@bookmail.kr', '춘천', '2026-08-20', TRUE);

SELECT customer_id AS 고객번호, name AS 이름, city AS 도시, birth_date AS 생일
FROM customers
WHERE email = 'jiwoo.han@bookmail.kr';
