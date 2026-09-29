-- runner: reset
-- 11장 11.2 «practice» 2: viewed_at 인덱스로 서울 8월 15일 오전 9시 한 시간 — Index Scan
CREATE INDEX page_views_viewed_at_idx ON page_views (viewed_at);

EXPLAIN (COSTS OFF)
SELECT view_id, book_id
FROM page_views
WHERE viewed_at >= '2026-08-15 09:00:00+09'
    AND viewed_at < '2026-08-15 10:00:00+09';
