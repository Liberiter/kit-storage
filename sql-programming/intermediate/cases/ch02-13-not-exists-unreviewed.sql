-- 2장 2.2 «따라 하기» 2단계 — NOT EXISTS 로 리뷰가 한 건도 없는 책을 뽑는다
SELECT books.book_id AS 도서번호, books.title AS 제목
FROM books
WHERE NOT EXISTS (SELECT 1 FROM reviews WHERE reviews.book_id = books.book_id)
ORDER BY books.book_id
LIMIT 5;
