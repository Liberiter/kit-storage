-- 9.3 따라 하기 3단계: HAVING에 count이 아닌 집계(avg)를 적는다
SELECT category AS 분야, round(avg(price), 1) AS 평균가격
FROM books
GROUP BY category
HAVING avg(price) >= 24000
ORDER BY 평균가격 DESC;
