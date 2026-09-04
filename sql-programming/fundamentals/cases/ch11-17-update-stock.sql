-- runner: reset
-- 11.2 따라 하기 1단계 — 열 하나를 고치고 확인한다
UPDATE books SET stock = 20 WHERE book_id = 8;

SELECT book_id AS 도서번호, title AS 제목, price AS 가격, stock AS 재고
FROM books
WHERE book_id = 8;
