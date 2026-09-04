-- exercise 1 해설: 가장 먼저 나온 책 (min(published_date) 서브쿼리)
SELECT book_id AS 도서번호, title AS 제목, published_date AS 출간일
FROM books
WHERE published_date = (SELECT min(published_date) FROM books)
ORDER BY book_id;
