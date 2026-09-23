-- runner: reset
-- 7장 7.2 «따라 하기» 1단계: DO NOTHING 은 이미 있는 책을 건너뛴다
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
SELECT book_id, supplier_price, supplier_stock, received_at
FROM supplier_feed
WHERE feed_date = '2026-08-25'
ON CONFLICT (book_id) DO NOTHING;

SELECT count(*) AS 공급현황줄수 FROM book_supply;

SELECT book_id, supplier_price, supplier_stock, updated_at
FROM book_supply
WHERE book_id = 19;
