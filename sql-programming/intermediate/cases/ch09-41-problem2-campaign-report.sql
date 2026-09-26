-- 9장 «도전하기» problem 2 해설: 8월(서울 날짜) 광고 캠페인별 조회 수, 체류 시간 중앙값, 끝까지 스크롤한 비율
WITH ad_views AS (
    SELECT
        context ->> 'utm' AS 캠페인,
        CAST(context ->> 'dwell_ms' AS integer) AS 체류ms,
        CAST(context ->> 'scroll_pct' AS integer) AS 스크롤
    FROM page_views
    WHERE context ? 'utm'
        AND viewed_at >= '2026-08-01 00:00:00+09'
        AND viewed_at < '2026-09-01 00:00:00+09'
)
SELECT
    캠페인,
    count(*) AS 조회수,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY 체류ms) AS 체류중앙값,
    round(100.0 * count(*) FILTER (WHERE 스크롤 = 100) / count(*), 1)
        AS "끝까지(%)"
FROM ad_views
GROUP BY 캠페인
ORDER BY 조회수 DESC;
