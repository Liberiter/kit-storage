-- 4장 4.2 «문제 상황»: 과학 분야에서 비싼 다섯 권
SELECT title AS 제목, price AS 가격
FROM books
WHERE category = '과학'
ORDER BY price DESC, book_id
LIMIT 5;
