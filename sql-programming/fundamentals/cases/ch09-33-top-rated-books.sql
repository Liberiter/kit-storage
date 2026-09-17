-- 9.3 따라 하기 4단계: 조인·WHERE·GROUP BY·HAVING·ORDER BY·LIMIT 종합
SELECT
    books.book_id AS 도서번호,
    books.title AS 제목,
    count(*) AS 리뷰수,
    round(avg(reviews.rating), 2) AS 평균별점
FROM books
INNER JOIN reviews ON books.book_id = reviews.book_id
GROUP BY books.book_id, books.title
HAVING count(*) >= 4
ORDER BY 평균별점 DESC, 도서번호
LIMIT 5;
