-- 4장 4.2 «흔한 실수»: 윈도우 함수는 WHERE 에 쓸 수 없다
SELECT title AS 제목, price AS 가격
FROM books
WHERE category = '과학'
    AND price > avg(price) OVER ()
ORDER BY price DESC, book_id;
