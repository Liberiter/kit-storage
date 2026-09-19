-- 4장 4.3 «흔한 실수»: 묶은 질의의 창은 그룹 키나 집계만 볼 수 있다
SELECT
    category AS 분야,
    count(*) AS 권수,
    round(avg(price) OVER (PARTITION BY title)) AS 평균가
FROM books
GROUP BY category;
