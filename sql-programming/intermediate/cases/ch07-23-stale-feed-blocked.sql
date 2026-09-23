-- runner: reset
-- 7장 7.2 «따라 하기» 6단계 둘째 블록: DO UPDATE 의 WHERE 가 오래된 피드를 막는다
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
VALUES (19, 5000, 5, '2026-07-01 00:00:00+00')
ON CONFLICT (book_id) DO UPDATE
SET supplier_price = EXCLUDED.supplier_price,
    supplier_stock = EXCLUDED.supplier_stock,
    updated_at = EXCLUDED.updated_at
WHERE book_supply.updated_at < EXCLUDED.updated_at;

SELECT book_id, supplier_price, supplier_stock, updated_at
FROM book_supply
WHERE book_id = 19;
