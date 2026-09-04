-- 4장 4.1 practice 2 풀이: 2026년 출간 도서를 최신순으로
SELECT title, published_date
FROM books
WHERE published_date >= '2026-01-01'
ORDER BY published_date DESC;
