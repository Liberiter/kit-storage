-- runner: reset
-- 7장 7.2 «흔한 실수»: EXCLUDED 를 빠뜨리면 어느 쪽 값인지 가릴 수 없다 (오류 기대)
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
VALUES (19, 6200, 62, '2026-08-25 06:30:19+00')
ON CONFLICT (book_id) DO UPDATE
SET supplier_price = supplier_price,
    supplier_stock = supplier_stock,
    updated_at = updated_at;
