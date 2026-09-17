-- 2장 2.2 «practice» 2 — 한 번도 팔린 적 없는 책
SELECT books.book_id AS 도서번호, books.title AS 제목, books.stock AS 재고
FROM books
WHERE NOT EXISTS (
    SELECT 1 FROM order_items WHERE order_items.book_id = books.book_id
)
ORDER BY books.book_id;
