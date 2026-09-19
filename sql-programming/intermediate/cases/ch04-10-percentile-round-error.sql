-- 4장 4.1 «흔한 실수»: 백분위 결과에 소수 자리를 지정하려다 만나는 타입 오류
SELECT round(percentile_cont(0.5) WITHIN GROUP (ORDER BY price), 1) AS 중앙값
FROM books;
