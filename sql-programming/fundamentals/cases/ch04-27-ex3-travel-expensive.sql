-- 4장 exercise 3 해설: 여행 분야를 정가 비싼 순으로 상위 5종
SELECT title AS 제목, price AS "정가(원)"
FROM books
WHERE category = '여행'
ORDER BY price DESC, book_id
LIMIT 5;
