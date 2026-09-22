-- 5장 «복습 exercise» 2 해설 (4장 — 통계 집계): 퍼짐이 큰 순으로 등수를 매긴다
WITH category_stat AS (
    SELECT
        category AS 분야,
        round(stddev(price)) AS 표준편차,
        percentile_cont(0.5) WITHIN GROUP (ORDER BY price) AS 중앙값
    FROM books
    GROUP BY category
)
SELECT
    rank() OVER (ORDER BY 표준편차 DESC) AS "퍼짐 순위",
    분야,
    표준편차,
    중앙값
FROM category_stat
ORDER BY 표준편차 DESC, 분야;
