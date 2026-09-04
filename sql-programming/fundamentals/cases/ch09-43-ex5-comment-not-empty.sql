-- 복습 exercise (5·7장) (b): 널인 comment는 `<> ''`를 통과하지 못한다
SELECT
    books.title AS 제목,
    count(*) AS 리뷰수,
    count(reviews.comment) AS 내용있는리뷰수
FROM books
INNER JOIN reviews ON books.book_id = reviews.book_id
WHERE reviews.comment <> ''
GROUP BY books.book_id, books.title
HAVING count(*) >= 5
ORDER BY 리뷰수 DESC, books.book_id
LIMIT 5;
