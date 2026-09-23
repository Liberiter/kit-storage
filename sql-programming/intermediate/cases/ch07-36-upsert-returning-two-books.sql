-- runner: reset
-- 7장 7.3 «practice» 1: 다른 두 책으로 삽입·갱신을 가른다
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
VALUES
    (1, 17000, 30, '2026-09-08 06:30:00+00'),
    (3, 9000, 12, '2026-09-08 06:30:00+00')
ON CONFLICT (book_id) DO UPDATE
SET supplier_price = EXCLUDED.supplier_price,
    supplier_stock = EXCLUDED.supplier_stock,
    updated_at = EXCLUDED.updated_at
RETURNING
    book_id,
    OLD.supplier_price AS 예전공급가,
    NEW.supplier_price AS 새공급가;
