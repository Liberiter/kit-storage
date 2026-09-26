-- 9장 9.1 «왜 그럴까요»: 같은 UTC 정오가 1월과 7월에 로스앤젤레스·런던에서는 다른 시각, 서울에서는 같은 시각
WITH moments AS (
    SELECT CAST('2026-01-15 12:00:00+00' AS timestamp with time zone) AS 순간
    UNION ALL
    SELECT CAST('2026-07-15 12:00:00+00' AS timestamp with time zone)
)
SELECT
    순간,
    순간 AT TIME ZONE 'America/Los_Angeles' AS 로스앤젤레스,
    순간 AT TIME ZONE 'Europe/London' AS 런던,
    순간 AT TIME ZONE 'Asia/Seoul' AS 서울
FROM moments
ORDER BY 순간;
