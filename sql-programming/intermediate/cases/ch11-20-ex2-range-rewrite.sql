-- runner: reset
-- 11장 «연습하기» exercise 2 해설: 조건을 viewed_at 의 반열린 범위로 — Index Scan, 결과는 지문과 같다
CREATE INDEX page_views_viewed_at_idx ON page_views (viewed_at);

EXPLAIN (COSTS OFF)
SELECT
    CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) AS 날짜,
    count(*) AS 모바일조회수
FROM page_views
WHERE viewed_at >= '2026-08-15 00:00:00+09'
    AND viewed_at < '2026-08-18 00:00:00+09'
    AND context ->> 'device' = 'mobile'
GROUP BY CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date)
ORDER BY 날짜;

SELECT
    CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) AS 날짜,
    count(*) AS 모바일조회수
FROM page_views
WHERE viewed_at >= '2026-08-15 00:00:00+09'
    AND viewed_at < '2026-08-18 00:00:00+09'
    AND context ->> 'device' = 'mobile'
GROUP BY CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date)
ORDER BY 날짜;
