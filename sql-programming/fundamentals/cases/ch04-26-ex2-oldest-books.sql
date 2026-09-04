-- 4장 exercise 2 해설: 가장 오래된 책 3종
SELECT title, published_date
FROM books
ORDER BY published_date, book_id
LIMIT 3;
