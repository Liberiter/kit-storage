-- runner: reset
-- 12장 12.2 «practice» 1: 입고 열 권을 식으로 더하는 한 문장 (혼자 실행)
UPDATE books SET stock = stock + 10 WHERE book_id = 4 RETURNING book_id, stock;
