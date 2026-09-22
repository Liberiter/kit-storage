-- 5장 «연습하기» exercise 4 해설: 순위·전일 대비·이레 평균을 한 표에
WITH daily_views AS (
    SELECT CAST(viewed_at AS date) AS 날짜, count(*) AS 조회수
    FROM page_views
    WHERE CAST(viewed_at AS date) BETWEEN '2026-06-01' AND '2026-06-14'
    GROUP BY CAST(viewed_at AS date)
)
SELECT
    날짜,
    조회수,
    rank() OVER (ORDER BY 조회수 DESC) AS 순위,
    조회수 - lag(조회수) OVER (ORDER BY 날짜) AS "전일 대비",
    round(avg(조회수) OVER (
        ORDER BY 날짜
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )) AS "이레 평균"
FROM daily_views
ORDER BY 날짜;
