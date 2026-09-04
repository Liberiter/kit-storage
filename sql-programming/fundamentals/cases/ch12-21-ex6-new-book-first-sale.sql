-- runner: reset
-- 복습 exercise 6(11장) 해설 — 신간 등록과 첫 판매를 한 덩어리로
BEGIN;
INSERT INTO books (
    title, author, category, price, page_count, published_date, stock
)
VALUES ('빛나는 계절', '한지우', '에세이', 17000, 232, '2026-08-20', 10);
UPDATE books SET stock = stock - 1 WHERE title = '빛나는 계절';
COMMIT;

SELECT book_id AS 도서번호, title AS 제목, price AS 가격, stock AS 재고
FROM books
WHERE title = '빛나는 계절';
