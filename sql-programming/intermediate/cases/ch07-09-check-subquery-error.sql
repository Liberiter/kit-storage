-- runner: reset
-- 7장 7.1 «왜 그럴까요»: CHECK 는 다른 표를 볼 수 없다 (오류 기대)
ALTER TABLE book_supply
ADD CONSTRAINT book_supply_price_under_max
CHECK (supplier_price <= (SELECT max(price) FROM books));
