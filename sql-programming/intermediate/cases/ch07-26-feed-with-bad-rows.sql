-- runner: reset
-- 7장 7.2 «practice» 1: UPSERT 는 겹침만 다루고 제약 위반은 그대로 막는다 (오류 기대)
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
SELECT book_id, supplier_price, supplier_stock, received_at
FROM supplier_feed
WHERE feed_date = '2026-09-01'
ON CONFLICT (book_id) DO UPDATE
SET supplier_price = EXCLUDED.supplier_price,
    supplier_stock = EXCLUDED.supplier_stock,
    updated_at = EXCLUDED.updated_at;
