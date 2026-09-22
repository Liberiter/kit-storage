-- 복습 exercise 1 해설 (2장) — 원장의 이메일 가운데 책숲 고객 표에 없는 것
SELECT count(*) AS 짝없는줄
FROM legacy.sales_ledger
WHERE NOT EXISTS (
    SELECT 1
    FROM customers
    WHERE customers.email = legacy.sales_ledger."고객이메일"
);
