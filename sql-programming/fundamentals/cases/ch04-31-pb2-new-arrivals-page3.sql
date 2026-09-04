-- 4장 problem 2 해설: 출간일 최신순 신간 목록의 3쪽 (한 쪽 5종)
SELECT title AS 제목, published_date AS 출간일
FROM books
ORDER BY published_date DESC, book_id
LIMIT 5
OFFSET 10;
