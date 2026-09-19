-- 4장 4.2 «따라 하기» 3단계: 창에 든 행 수는 LIMIT 과 무관하다
SELECT title AS 제목, price AS 가격, count(*) OVER () AS "창에 든 행 수"
FROM books
WHERE category = '과학'
ORDER BY price DESC, book_id
LIMIT 5;
