-- runner: reset
-- 7장 7.3 «따라 하기» 4단계: UPSERT 가 넣은 줄과 고친 줄을 OLD 로 가른다
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
VALUES
    (19, 6200, 62, '2026-08-25 06:30:19+00'),
    (2, 6300, 63, '2026-09-01 06:30:02+00')
ON CONFLICT (book_id) DO UPDATE
SET supplier_price = EXCLUDED.supplier_price,
    supplier_stock = EXCLUDED.supplier_stock,
    updated_at = EXCLUDED.updated_at
RETURNING
    book_id,
    OLD.supplier_price AS 예전공급가,
    NEW.supplier_price AS 새공급가;
