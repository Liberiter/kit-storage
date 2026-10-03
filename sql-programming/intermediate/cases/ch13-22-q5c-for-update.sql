-- runner: reset
-- 13장(exit assessment) 문항 5 지문 (다): FOR UPDATE로 잠그며 읽고 차감 (혼자 실행)
BEGIN;
SELECT stock AS 읽은재고 FROM books WHERE book_id = 6 FOR UPDATE;
UPDATE books SET stock = stock - 1 WHERE book_id = 6;
COMMIT;
SELECT stock AS 재고 FROM books WHERE book_id = 6;
