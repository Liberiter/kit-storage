-- runner: reset
-- 6.2 흔한 실수 — 외래키를 걸지 않으면 가리킬 곳이 없는 줄도 들어간다
CREATE TABLE ledger_orders_no_fk (
    order_no text PRIMARY KEY,
    customer_email text NOT NULL
);

INSERT INTO ledger_orders_no_fk (order_no, customer_email)
VALUES ('ORD-99999', 'nobody@bookmail.kr');

SELECT order_no AS 주문번호, customer_email AS 고객이메일
FROM ledger_orders_no_fk
WHERE order_no = 'ORD-99999';
