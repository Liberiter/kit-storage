-- 4장 problem 1 해설: 요리 분야 재고 있는 책을 출간일 최신순으로 3종
SELECT title AS 제목, published_date AS 출간일, stock AS 재고
FROM books
WHERE category = '요리' AND stock >= 1
ORDER BY published_date DESC, book_id
LIMIT 3;
