-- 4장 4.1 «흔한 실수»: 백분위 인자는 0 과 1 사이여야 한다
SELECT percentile_cont(50) WITHIN GROUP (ORDER BY price) AS 중앙값 FROM books;
