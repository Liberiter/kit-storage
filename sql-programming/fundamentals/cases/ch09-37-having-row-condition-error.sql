-- 9.3 흔한 실수: 그룹 키도 집계도 아닌 열을 HAVING에 적으면 오류 (오류 기대, exit 3)
SELECT books.category AS 분야, count(*) AS 권수
FROM books
GROUP BY books.category
HAVING books.price >= 30000
ORDER BY 권수 DESC;
