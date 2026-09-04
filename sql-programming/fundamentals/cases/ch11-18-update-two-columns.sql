-- runner: reset
-- 11.2 따라 하기 2단계 — 열 두 개를 한 문장으로 고친다
UPDATE books SET price = 17500, stock = 25 WHERE book_id = 8;

SELECT book_id AS 도서번호, title AS 제목, price AS 가격, stock AS 재고
FROM books
WHERE book_id = 8;
