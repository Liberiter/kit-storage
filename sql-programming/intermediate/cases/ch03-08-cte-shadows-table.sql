-- 3장 3.1 «흔한 실수»: CTE 이름이 테이블 이름과 같으면 CTE 가 이긴다
WITH books AS (
    SELECT book_id, title, price FROM books WHERE category = '과학'
)
SELECT count(*) AS 권수 FROM books;
