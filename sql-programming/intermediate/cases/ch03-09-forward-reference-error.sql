-- 3장 3.1 «흔한 실수»: 앞 CTE 가 뒤에 정의한 CTE 를 부르면 오류다
WITH cheap_count AS (
    SELECT count(*) AS 권수 FROM cheap_books
),
cheap_books AS (
    SELECT book_id FROM books WHERE price < 10000
)
SELECT 권수 FROM cheap_count;
