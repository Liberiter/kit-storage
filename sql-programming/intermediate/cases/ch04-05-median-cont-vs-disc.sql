-- 4장 4.1 «따라 하기» 4단계: percentile_cont 와 percentile_disc 의 차이
SELECT
    percentile_cont(0.5) WITHIN GROUP (ORDER BY price) AS "중앙값(cont)",
    percentile_disc(0.5) WITHIN GROUP (ORDER BY price) AS "중앙값(disc)"
FROM books
WHERE category = '에세이';
