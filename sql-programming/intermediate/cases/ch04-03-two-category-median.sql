-- 4장 4.1 «따라 하기» 2단계: 중앙값 (백분위 0.5)
SELECT
    category AS 분야,
    round(avg(price)) AS 평균가,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY price) AS 중앙값
FROM books
WHERE category IN ('에세이', '요리')
GROUP BY category
ORDER BY category;
