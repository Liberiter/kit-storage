-- 9장 «복습 exercise» 1 해설 (4장): 기기별 체류 시간 ↔ 스크롤 비율 상관계수와 체류 시간 90백분위
WITH visits AS (
    SELECT
        context ->> 'device' AS 기기,
        CAST(context ->> 'dwell_ms' AS integer) AS 체류ms,
        CAST(context ->> 'scroll_pct' AS integer) AS 스크롤
    FROM page_views
)
SELECT
    기기,
    round(CAST(corr(체류ms, 스크롤) AS numeric), 3) AS 상관계수,
    percentile_cont(0.9) WITHIN GROUP (ORDER BY 체류ms) AS 체류90백분위
FROM visits
GROUP BY 기기
ORDER BY 기기;
