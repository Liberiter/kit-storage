-- runner: reset
-- 7장 7.2 «practice» 2: 쓸 수 있는 줄만 골라 DO NOTHING 으로 넣는다
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
SELECT book_id, supplier_price, supplier_stock, received_at
FROM supplier_feed
WHERE supplier_price > 0
    AND EXISTS (
        SELECT 1 FROM books WHERE books.book_id = supplier_feed.book_id
    )
ON CONFLICT (book_id) DO NOTHING;

SELECT count(*) AS 공급현황줄수 FROM book_supply;
