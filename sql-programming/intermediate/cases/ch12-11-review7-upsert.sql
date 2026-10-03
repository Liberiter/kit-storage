-- runner: reset
-- 12장 복습 exercise 1 (7장) 해설: 2번 책의 공급 정보를 UPSERT 한 문장으로 적재하고 확인한다 (혼자 실행)
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
VALUES (2, 6600, 20, '2026-09-08 06:30:00+00')
ON CONFLICT (book_id) DO UPDATE
SET supplier_price = EXCLUDED.supplier_price,
    supplier_stock = EXCLUDED.supplier_stock,
    updated_at = EXCLUDED.updated_at;

SELECT book_id, supplier_price, supplier_stock
FROM book_supply
WHERE book_id = 2;
