-- 1장 «연습하기» exercise 1: 책마다 리뷰 수와 별점 4 이상 리뷰 수
SELECT
    books.book_id AS 도서번호,
    books.title AS 제목,
    count(*) AS 리뷰수,
    count(*) FILTER (WHERE reviews.rating >= 4) AS 호평수
FROM books
INNER JOIN reviews ON books.book_id = reviews.book_id
GROUP BY books.book_id, books.title
ORDER BY 리뷰수 DESC, 도서번호
LIMIT 5;
