-- 3장 3.3 «문제 상황»: 묶은 표에는 집계하지 않은 열을 실을 수 없다
SELECT category AS 분야, title AS 제목, max(price) AS 최고가
FROM books
GROUP BY category;
