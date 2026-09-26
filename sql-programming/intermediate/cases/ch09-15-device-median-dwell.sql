-- 9장 9.2 «따라 하기» 2단계: 값을 꺼내 타입을 입힌 뒤 기기별 조회 수와 체류 시간 중앙값
WITH visits AS (
    SELECT
        context ->> 'device' AS 기기,
        CAST(context ->> 'dwell_ms' AS integer) AS 체류ms
    FROM page_views
)
SELECT
    기기,
    count(*) AS 조회수,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY 체류ms) AS 체류중앙값
FROM visits
GROUP BY 기기
ORDER BY 조회수 DESC;
