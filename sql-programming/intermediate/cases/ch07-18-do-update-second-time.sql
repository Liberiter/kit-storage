-- runner: reset
-- 7장 7.2 «따라 하기» 2단계: 한 문장 안에 같은 책이 두 줄이면 DO UPDATE 가 막힌다 (오류 기대)
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
SELECT book_id, supplier_price, supplier_stock, received_at
FROM supplier_feed
WHERE feed_date = '2026-08-25'
ON CONFLICT (book_id) DO UPDATE
SET supplier_price = EXCLUDED.supplier_price,
    supplier_stock = EXCLUDED.supplier_stock,
    updated_at = EXCLUDED.updated_at;
