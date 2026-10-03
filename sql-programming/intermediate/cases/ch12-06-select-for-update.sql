-- runner: reset
-- 12장 12.2 «따라 하기» 2단계: FOR UPDATE로 읽어 잠근 뒤 읽은 값으로 쓰고 확정한다 (혼자 실행)
BEGIN;
SELECT stock FROM books WHERE book_id = 1 FOR UPDATE;
UPDATE books SET stock = 4 WHERE book_id = 1;
COMMIT;

SELECT stock FROM books WHERE book_id = 1;
