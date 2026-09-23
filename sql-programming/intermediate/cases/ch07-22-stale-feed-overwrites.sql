-- runner: reset
-- 7장 7.2 «따라 하기» 6단계 첫 블록: 오래된 피드가 새 값을 덮는다
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
VALUES (19, 5000, 5, '2026-07-01 00:00:00+00')
ON CONFLICT (book_id) DO UPDATE
SET supplier_price = EXCLUDED.supplier_price,
    supplier_stock = EXCLUDED.supplier_stock,
    updated_at = EXCLUDED.updated_at;

SELECT book_id, supplier_price, supplier_stock, updated_at
FROM book_supply
WHERE book_id = 19;
