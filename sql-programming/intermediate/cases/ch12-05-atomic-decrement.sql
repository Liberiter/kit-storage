-- runner: reset
-- 12장 12.2 «따라 하기» 1단계: 읽은 값이 아니라 식으로 한 권을 줄이는 한 문장 (혼자 실행)
UPDATE books SET stock = stock - 1 WHERE book_id = 1 RETURNING book_id, stock;
