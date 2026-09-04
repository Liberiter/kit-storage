-- 6.3 practice 1 풀이: 제목이 가장 긴 다섯 종
SELECT title, length(title) AS 글자수
FROM books
ORDER BY 글자수 DESC, book_id
LIMIT 5;
