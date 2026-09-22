-- runner: reset
-- 6.2 왜 그럴까요 — 가리킬 표가 아직 없으면 자식 표를 만들 수 없다 (오류 기대)
CREATE TABLE ledger_orders (
    order_no text PRIMARY KEY,
    order_date date NOT NULL,
    customer_email text NOT NULL REFERENCES ledger_customers (email),
    status text NOT NULL,
    shipped_date date
);
