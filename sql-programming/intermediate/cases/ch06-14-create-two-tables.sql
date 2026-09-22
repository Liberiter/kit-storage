-- runner: reset
-- 6.2 개념 — 서식 규칙 R81~R84의 예제. 본문은 출력을 싣지 않는다
CREATE TABLE ledger_customers (
    email text PRIMARY KEY,
    name text NOT NULL,
    city text NOT NULL
);

CREATE TABLE ledger_orders (
    order_no text PRIMARY KEY,
    order_date date NOT NULL,
    customer_email text NOT NULL REFERENCES ledger_customers (email),
    status text NOT NULL,
    shipped_date date
);
