-- runner: reset
-- 7장 7.1 «흔한 실수»: NOT NULL 을 함께 걸어야 널이 막힌다 (오류 기대)
CREATE TABLE trial_supply (
    book_id integer PRIMARY KEY,
    supplier_price integer NOT NULL CHECK (supplier_price > 0),
    barcode text UNIQUE
);

INSERT INTO trial_supply (book_id, supplier_price, barcode)
VALUES (1, NULL, NULL);
