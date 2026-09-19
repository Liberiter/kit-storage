-- 4장 4.1 «흔한 실수»: 자리 수를 지정하지 않는 round 로 고친 질의
SELECT round(percentile_cont(0.5) WITHIN GROUP (ORDER BY price)) AS 중앙값
FROM books;
