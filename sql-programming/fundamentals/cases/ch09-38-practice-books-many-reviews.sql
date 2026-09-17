-- 9.3 practice 1 풀이: 리뷰가 다섯 건 이상 달린 책
SELECT books.book_id AS 도서번호, books.title AS 제목, count(*) AS 리뷰수
FROM books
INNER JOIN reviews ON books.book_id = reviews.book_id
GROUP BY books.book_id, books.title
HAVING count(*) >= 5
ORDER BY 리뷰수 DESC, 도서번호
LIMIT 5;
