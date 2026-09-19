-- 4장 4.2 «문제 상황»: 평균을 붙이려고 GROUP BY 를 쓰면 제목이 막힌다
SELECT title AS 제목, price AS 가격, round(avg(price)) AS 평균가
FROM books
WHERE category = '과학'
GROUP BY category;
