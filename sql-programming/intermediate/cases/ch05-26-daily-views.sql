-- 5장 5.3 «문제 상황»: 날마다 들쭉날쭉한 조회 수
WITH daily_views AS (
    SELECT CAST(viewed_at AS date) AS 날짜, count(*) AS 조회수
    FROM page_views
    WHERE CAST(viewed_at AS date) BETWEEN '2026-06-01' AND '2026-06-14'
    GROUP BY CAST(viewed_at AS date)
)
SELECT 날짜, 조회수
FROM daily_views
ORDER BY 날짜;
