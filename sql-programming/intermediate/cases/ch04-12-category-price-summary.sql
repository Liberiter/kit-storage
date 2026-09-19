-- 4장 4.1 «practice» 1: 여덟 분야의 가격 분포 요약
SELECT
    category AS 분야,
    count(*) AS 권수,
    round(avg(price)) AS 평균가,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY price) AS 중앙값,
    round(stddev(price)) AS 표준편차
FROM books
GROUP BY category
ORDER BY 중앙값 DESC, 분야;
