-- 9.2 흔한 실수: ORDER BY가 없으면 그룹이 나오는 차례는 보장되지 않는다 (4장)
SELECT category AS 분야, count(*) AS 권수 FROM books GROUP BY category;
