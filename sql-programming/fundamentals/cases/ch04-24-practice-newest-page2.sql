-- 4장 4.2 practice 2 풀이: 출간일 최신순 4~6위 (한 쪽 3종짜리 목록의 2쪽)
SELECT title, published_date
FROM books
ORDER BY published_date DESC, book_id
LIMIT 3
OFFSET 3;
