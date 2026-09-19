-- 3장 3.1 «흔한 실수»: 이름을 붙여 놓고 본 질의에서 부르지 않으면 조용히 무시된다
WITH cheap_books AS (
    SELECT book_id, title, price FROM books WHERE price < 10000
)
SELECT count(*) AS 권수 FROM books;

WITH cheap_books AS (
    SELECT book_id, title, price FROM books WHERE price < 10000
)
SELECT count(*) AS 권수 FROM cheap_books;
