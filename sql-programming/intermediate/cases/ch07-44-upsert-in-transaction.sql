-- runner: reset
-- 7장 «복습 exercise» 3 해설 (앞 코스 11·12장 — DML·트랜잭션): 확인한 뒤 되돌린다
BEGIN;
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
VALUES (19, 5000, 5, '2026-09-08 06:30:00+00')
ON CONFLICT (book_id) DO UPDATE
SET supplier_price = EXCLUDED.supplier_price,
    supplier_stock = EXCLUDED.supplier_stock,
    updated_at = EXCLUDED.updated_at
RETURNING
    book_id,
    OLD.supplier_price AS 예전공급가,
    NEW.supplier_price AS 새공급가;
ROLLBACK;

SELECT book_id, supplier_price, supplier_stock, updated_at
FROM book_supply
WHERE book_id = 19;
