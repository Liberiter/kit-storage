-- 4장 «도전하기» problem 1 해설: 분야별 가격 분포 보고서
WITH category_stat AS (
    SELECT
        category AS 분야,
        count(*) AS 권수,
        round(avg(price)) AS 평균가,
        percentile_cont(0.5) WITHIN GROUP (ORDER BY price) AS 중앙값,
        round(stddev(price)) AS 표준편차
    FROM books
    GROUP BY category
)
SELECT
    분야,
    권수,
    round(100.0 * 권수 / sum(권수) OVER (), 1) AS "권수 비중(%)",
    평균가,
    중앙값,
    표준편차
FROM category_stat
ORDER BY 표준편차 DESC, 분야;
