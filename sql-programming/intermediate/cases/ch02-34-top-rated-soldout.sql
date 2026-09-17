-- 2장 «연습하기» exercise 3 해설 — 5점 리뷰를 받은 적이 있는 품절 도서
SELECT books.book_id AS 도서번호, books.title AS 제목, books.category AS 분야
FROM books
WHERE books.stock = 0
    AND EXISTS (
        SELECT 1
        FROM reviews
        WHERE reviews.book_id = books.book_id
            AND reviews.rating = 5
    )
ORDER BY books.book_id;
