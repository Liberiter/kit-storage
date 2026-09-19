-- 4장 4.2 «따라 하기» 1단계: OVER () 로 분야 평균을 행마다 붙인다
SELECT title AS 제목, price AS 가격, round(avg(price) OVER ()) AS "분야 평균"
FROM books
WHERE category = '과학'
ORDER BY price DESC, book_id
LIMIT 5;
