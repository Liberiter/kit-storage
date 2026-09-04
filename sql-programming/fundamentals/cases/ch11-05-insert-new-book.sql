-- runner: reset
-- 11.1 따라 하기 1단계 — 새 책 한 권을 넣고 확인한다
INSERT INTO books (
    title, author, category, price, page_count, published_date, stock
)
VALUES ('빛나는 계절', '한지우', '에세이', 17000, 232, '2026-08-20', 10);

SELECT book_id AS 도서번호, title AS 제목, price AS 가격, stock AS 재고
FROM books
WHERE title = '빛나는 계절';
