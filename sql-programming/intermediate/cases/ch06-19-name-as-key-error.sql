-- runner: reset
-- 6.2 왜 그럴까요 — 이름을 기본키로 삼으면 동명이인이 들어오지 못한다 (오류 기대)
CREATE TABLE ledger_customers_by_name (
    name text PRIMARY KEY,
    email text NOT NULL,
    city text NOT NULL
);

INSERT INTO ledger_customers_by_name (name, email, city)
SELECT DISTINCT "고객명", "고객이메일", "고객도시"
FROM legacy.sales_ledger;
