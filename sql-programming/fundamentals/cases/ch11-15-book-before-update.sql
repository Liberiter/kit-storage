-- 11.2 문제 상황 — 고칠 대상을 먼저 조회해 확인한다
SELECT book_id AS 도서번호, title AS 제목, price AS 가격, stock AS 재고
FROM books
WHERE book_id = 8;
