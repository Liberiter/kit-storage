-- runner: reset
-- 11장 «연습하기» exercise 2 지문: 동료의 질의 — viewed_at 인덱스가 있는데 Parallel Seq Scan
CREATE INDEX page_views_viewed_at_idx ON page_views (viewed_at);

EXPLAIN (COSTS OFF)
SELECT
    CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) AS 날짜,
    count(*) AS 모바일조회수
FROM page_views
WHERE CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) >= '2026-08-15'
    AND CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) < '2026-08-18'
    AND context ->> 'device' = 'mobile'
GROUP BY CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date)
ORDER BY 날짜;

SELECT
    CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) AS 날짜,
    count(*) AS 모바일조회수
FROM page_views
WHERE CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) >= '2026-08-15'
    AND CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) < '2026-08-18'
    AND context ->> 'device' = 'mobile'
GROUP BY CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date)
ORDER BY 날짜;
