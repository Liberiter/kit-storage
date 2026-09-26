-- 9장 «복습 exercise» 2 해설 (5장): 5장 exercise 4의 보고서(순위·전일 대비·이레 평균)를 서울 날짜로 다시
WITH daily_views AS (
    SELECT
        CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) AS 날짜,
        count(*) AS 조회수
    FROM page_views
    WHERE viewed_at >= '2026-06-01 00:00:00+09'
        AND viewed_at < '2026-06-15 00:00:00+09'
    GROUP BY CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date)
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
