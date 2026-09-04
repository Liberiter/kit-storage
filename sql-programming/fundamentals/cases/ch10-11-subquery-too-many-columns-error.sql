-- 10.1 흔한 실수: IN의 서브쿼리가 열을 둘 이상 고르면 오류 (exit 3)
SELECT title AS 제목
FROM books
WHERE book_id IN (SELECT book_id, rating FROM reviews);
