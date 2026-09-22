-- 5장 «도전하기» problem 3 해설: 8월 하순 조회 흐름 보고서
WITH daily_views AS (
    SELECT CAST(viewed_at AS date) AS 날짜, count(*) AS 조회수
    FROM page_views
    WHERE CAST(viewed_at AS date) BETWEEN '2026-08-17' AND '2026-08-30'
    GROUP BY CAST(viewed_at AS date)
),
with_trend AS (
    SELECT
        날짜,
        조회수,
        조회수 - lag(조회수) OVER (ORDER BY 날짜) AS "전일 대비",
        round(avg(조회수) OVER (
            ORDER BY 날짜
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )) AS "이레 평균"
    FROM daily_views
)
SELECT 날짜, 조회수, "전일 대비", "이레 평균"
FROM with_trend
WHERE 날짜 >= '2026-08-23'
ORDER BY 날짜;
