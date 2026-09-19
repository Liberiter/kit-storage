-- 4장 4.1 «흔한 실수»: WITHIN GROUP 을 빠뜨리면 그런 함수가 없다고 한다
SELECT percentile_cont(0.5) AS 중앙값 FROM books WHERE category = '에세이';
