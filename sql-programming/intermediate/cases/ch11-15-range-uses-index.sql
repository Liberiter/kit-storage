-- runner: reset
-- 11장 11.2 «흔한 실수» 1: 열은 그대로 두고 상수 쪽에 범위를 적으면 Index Scan, 센 수는 같다
CREATE INDEX page_views_viewed_at_idx ON page_views (viewed_at);

EXPLAIN (COSTS OFF)
SELECT view_id, book_id
FROM page_views
WHERE viewed_at >= '2026-08-15 00:00:00+09'
    AND viewed_at < '2026-08-16 00:00:00+09';

SELECT count(*) AS 조회수
FROM page_views
WHERE viewed_at >= '2026-08-15 00:00:00+09'
    AND viewed_at < '2026-08-16 00:00:00+09';
