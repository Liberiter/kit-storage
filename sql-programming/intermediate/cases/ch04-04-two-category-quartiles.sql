-- 4장 4.1 «따라 하기» 3단계: 사분위 셋을 한 줄에
SELECT
    category AS 분야,
    percentile_cont(0.25) WITHIN GROUP (ORDER BY price) AS "1사분위",
    percentile_cont(0.5) WITHIN GROUP (ORDER BY price) AS 중앙값,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY price) AS "3사분위"
FROM books
WHERE category IN ('에세이', '요리')
GROUP BY category
ORDER BY category;
