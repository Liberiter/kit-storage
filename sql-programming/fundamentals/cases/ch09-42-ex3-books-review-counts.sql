-- exercise 3 해설: 리뷰가 하나도 없는 책까지 포함한 책별 리뷰 수 (LEFT JOIN + count(열))
SELECT
    books.book_id AS 도서번호,
    books.title AS 제목,
    count(reviews.review_id) AS 리뷰수
FROM books
LEFT JOIN reviews ON books.book_id = reviews.book_id
GROUP BY books.book_id, books.title
ORDER BY 리뷰수, 도서번호
LIMIT 5;
