-- runner: reset
-- 7장 7.3 «practice» 2: 없는 책 번호가 든 줄을 지우면서 내용을 받아 둔다
DELETE FROM supplier_feed
WHERE NOT EXISTS (
    SELECT 1 FROM books WHERE books.book_id = supplier_feed.book_id
)
RETURNING feed_id, feed_date, book_id, supplier_price;
