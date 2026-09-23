-- runner: reset
-- 7장 7.2 «문제 상황»: 그냥 INSERT 하면 이미 있는 책에서 막힌다 (오류 기대)
SELECT count(*) AS 공급현황줄수 FROM book_supply;

INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
SELECT book_id, supplier_price, supplier_stock, received_at
FROM supplier_feed
WHERE feed_date = '2026-08-25';
