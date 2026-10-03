-- runner: reset
-- 13장(exit assessment) 문항 5 지문 (나): 조건을 건 한 문장 차감 (혼자 실행)
UPDATE books SET stock = stock - 1 WHERE book_id = 6 AND stock >= 1;
SELECT stock AS 재고 FROM books WHERE book_id = 6;
