-- 4장 exercise 4 해설: 정가 1만~2만 원인 책을 출간일 최신순으로 상위 5종
SELECT title, price, published_date
FROM books
WHERE price BETWEEN 10000 AND 20000
ORDER BY published_date DESC, book_id
LIMIT 5;
