-- runner: reset
-- 12장 12.2 «practice» 2: 4번 책 재고를 FOR UPDATE로 읽고, 읽은 값에 10을 더해 쓴다 (혼자 실행)
BEGIN;
SELECT stock FROM books WHERE book_id = 4 FOR UPDATE;
UPDATE books SET stock = 15 WHERE book_id = 4;
COMMIT;

SELECT stock FROM books WHERE book_id = 4;
