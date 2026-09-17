-- 2장 2.2 «문제 상황» — 조인해 세면 책이 아니라 리뷰가 세어진다
SELECT
    books.book_id AS 도서번호,
    books.title AS 제목,
    reviews.rating AS 별점
FROM books
INNER JOIN reviews ON books.book_id = reviews.book_id
WHERE books.book_id <= 4
ORDER BY books.book_id, reviews.review_id;

SELECT count(*) AS "조인한 줄 수"
FROM books
INNER JOIN reviews ON books.book_id = reviews.book_id;
