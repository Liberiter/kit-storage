-- 복습 exercise 5 (3장) 해설: 제목에 '여행'이 들고 평균 가격을 넘는 책
SELECT book_id AS 도서번호, title AS 제목, price AS 가격
FROM books
WHERE title LIKE '%여행%' AND price > (SELECT avg(price) FROM books)
ORDER BY price DESC, book_id
LIMIT 5;
