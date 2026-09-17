-- 9.1 흔한 실수: SELECT 뒤의 DISTINCT와 count의 괄호 안 DISTINCT는 하는 일이 다르다
SELECT DISTINCT
    count(book_id) AS 리뷰수,
    count(DISTINCT book_id) AS 리뷰가달린책수
FROM reviews;
