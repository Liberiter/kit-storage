-- 9.2 따라 하기 3단계: WHERE로 행을 먼저 거른 뒤 그룹으로 묶는다
SELECT category AS 분야, count(*) AS 권수
FROM books
WHERE price >= 30000
GROUP BY category
ORDER BY 권수 DESC, 분야;
