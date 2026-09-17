-- 복습 exercise (5·7장) (a) 해설: 리뷰 다섯 건 이상인 책의 리뷰 수와 내용 있는 리뷰 수
SELECT
    books.title AS 제목,
    count(*) AS 리뷰수,
    count(reviews.comment) AS 내용있는리뷰수
FROM books
INNER JOIN reviews ON books.book_id = reviews.book_id
GROUP BY books.book_id, books.title
HAVING count(*) >= 5
ORDER BY 리뷰수 DESC, books.book_id
LIMIT 5;
