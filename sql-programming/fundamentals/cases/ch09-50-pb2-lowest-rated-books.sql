-- problem 2 해설: 리뷰가 네 건 이상 달린 책 중 평균 별점이 낮은 다섯 권
SELECT
    books.book_id AS 도서번호,
    books.title AS 제목,
    count(*) AS 리뷰수,
    round(avg(reviews.rating), 2) AS 평균별점
FROM books
INNER JOIN reviews ON books.book_id = reviews.book_id
GROUP BY books.book_id, books.title
HAVING count(*) >= 4
ORDER BY 평균별점, 도서번호
LIMIT 5;
