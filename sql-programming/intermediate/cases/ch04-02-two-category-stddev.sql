-- 4장 4.1 «따라 하기» 1단계: 표준편차를 한 칸 더한다
SELECT
    category AS 분야,
    count(*) AS 권수,
    round(avg(price)) AS 평균가,
    round(stddev(price)) AS 표준편차
FROM books
WHERE category IN ('에세이', '요리')
GROUP BY category
ORDER BY category;
