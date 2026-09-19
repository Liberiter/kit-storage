-- 3장 3.1 «왜 그럴까요»: 같은 답을 서브쿼리로도 CTE 로도 쓸 수 있다
SELECT book_id AS 도서번호, title AS 제목, price AS 가격
FROM books
WHERE price > (SELECT avg(price) FROM books)
ORDER BY price DESC, book_id
LIMIT 5;

WITH average_price AS (
    SELECT avg(price) AS 평균가 FROM books
)
SELECT book_id AS 도서번호, title AS 제목, price AS 가격
FROM books
WHERE price > (SELECT 평균가 FROM average_price)
ORDER BY price DESC, book_id
LIMIT 5;
