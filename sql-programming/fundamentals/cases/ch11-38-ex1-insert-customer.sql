-- runner: reset
-- exercise 1 해설 — 새 손님을 넣고 확인한다
INSERT INTO customers (
    name, email, city, signup_date, marketing_opt_in, birth_date
)
VALUES (
    '서다은', 'daeun.seo@bookmail.kr', '제주', '2026-08-21', FALSE, '1994-02-17'
);

SELECT customer_id AS 고객번호, name AS 이름, city AS 도시, birth_date AS 생일
FROM customers
WHERE email = 'daeun.seo@bookmail.kr';
