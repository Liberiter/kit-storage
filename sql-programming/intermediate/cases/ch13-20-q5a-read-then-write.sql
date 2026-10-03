-- runner: reset
-- 13장(exit assessment) 문항 5 지문 (가): 읽은 값으로 계산한 수를 적는 차감 (혼자 실행)
BEGIN;
SELECT stock AS 읽은재고 FROM books WHERE book_id = 6;
UPDATE books SET stock = 0 WHERE book_id = 6;
COMMIT;
SELECT stock AS 재고 FROM books WHERE book_id = 6;
