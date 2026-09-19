-- 4장 4.2 «흔한 실수»: OVER 뒤의 괄호는 비어 있어도 적는다
SELECT title AS 제목, round(avg(price) OVER) AS 평균가
FROM books
WHERE category = '과학';
