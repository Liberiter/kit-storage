-- 5장 5.1 «흔한 실수»: 인자가 없다고 괄호까지 빼면 구문 오류 (오류 기대)
SELECT title AS 제목, rank OVER (ORDER BY price DESC) AS 순위
FROM books
WHERE category = '과학';
