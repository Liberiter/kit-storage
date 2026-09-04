-- runner: reset
-- 11.2 따라 하기 3단계 — 지금 값을 재료로 쓰는 식을 대입한다
UPDATE books SET stock = stock - 1 WHERE book_id = 5;

SELECT book_id AS 도서번호, title AS 제목, stock AS 재고
FROM books
WHERE book_id = 5;
