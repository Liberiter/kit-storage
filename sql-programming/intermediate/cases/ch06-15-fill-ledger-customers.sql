-- runner: reset
-- 6.2 따라 하기 2단계 — 고객 표를 만들고 원장에서 채운다
CREATE TABLE ledger_customers (
    email text PRIMARY KEY,
    name text NOT NULL,
    city text NOT NULL
);

INSERT INTO ledger_customers (email, name, city)
SELECT DISTINCT "고객이메일", "고객명", "고객도시"
FROM legacy.sales_ledger;

SELECT count(*) AS 고객수 FROM ledger_customers;
