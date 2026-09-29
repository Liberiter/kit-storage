-- runner: reset
-- 11장 «복습 exercise» 1 해설 (2장): NOT EXISTS 로 고치고 계획을 읽는다 — Hash Right Anti Join, page_views 쪽은 Index Scan
CREATE INDEX page_views_viewed_at_idx ON page_views (viewed_at);

EXPLAIN (COSTS OFF)
SELECT customers.customer_id, customers.name
FROM customers
WHERE NOT EXISTS (
    SELECT 1
    FROM page_views
    WHERE page_views.customer_id = customers.customer_id
        AND page_views.viewed_at >= '2026-08-31 00:00:00+09'
        AND page_views.viewed_at < '2026-09-01 00:00:00+09'
);

SELECT customers.customer_id, customers.name
FROM customers
WHERE NOT EXISTS (
    SELECT 1
    FROM page_views
    WHERE page_views.customer_id = customers.customer_id
        AND page_views.viewed_at >= '2026-08-31 00:00:00+09'
        AND page_views.viewed_at < '2026-09-01 00:00:00+09'
);
