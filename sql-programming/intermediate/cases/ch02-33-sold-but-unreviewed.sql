-- 2장 «연습하기» exercise 2 해설 — 팔린 적은 있지만 리뷰가 한 건도 없는 책
SELECT count(*) AS 권수
FROM books
WHERE EXISTS (
    SELECT 1 FROM order_items WHERE order_items.book_id = books.book_id
)
    AND NOT EXISTS (
        SELECT 1 FROM reviews WHERE reviews.book_id = books.book_id
    );

SELECT books.book_id AS 도서번호, books.title AS 제목
FROM books
WHERE EXISTS (
    SELECT 1 FROM order_items WHERE order_items.book_id = books.book_id
)
    AND NOT EXISTS (
        SELECT 1 FROM reviews WHERE reviews.book_id = books.book_id
    )
ORDER BY books.book_id
LIMIT 5;
