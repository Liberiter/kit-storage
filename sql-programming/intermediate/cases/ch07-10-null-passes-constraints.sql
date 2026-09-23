-- runner: reset
-- 7장 7.1 «왜 그럴까요»: 널은 CHECK 도 UNIQUE 도 빠져나간다
CREATE TABLE trial_supply (
    book_id integer PRIMARY KEY,
    supplier_price integer CHECK (supplier_price > 0),
    barcode text UNIQUE
);

INSERT INTO trial_supply (book_id, supplier_price, barcode)
VALUES
    (1, NULL, NULL),
    (2, NULL, NULL);

SELECT book_id, supplier_price, barcode FROM trial_supply ORDER BY book_id;
