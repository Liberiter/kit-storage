-- 9장 «연습하기» exercise 2 해설: 끝까지 스크롤한 조회의 수와 체류 시간 중앙값
WITH visits AS (
    SELECT CAST(context ->> 'dwell_ms' AS integer) AS 체류ms
    FROM page_views
    WHERE context @> '{"scroll_pct": 100}'
)
SELECT
    count(*) AS 조회수,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY 체류ms) AS 체류중앙값
FROM visits;
