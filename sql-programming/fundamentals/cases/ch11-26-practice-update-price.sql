-- runner: reset
-- 11.2 practice 1 풀이 — 한 권의 가격을 고치고 확인한다
UPDATE books SET price = 25000 WHERE book_id = 12;

SELECT book_id AS 도서번호, title AS 제목, price AS 가격
FROM books
WHERE book_id = 12;
