-- runner: reset
-- 11장 «연습하기» exercise 3: 인덱스가 둘일 때 — 더 적게 고르는 조건의 인덱스가 Index Cond, 나머지는 Filter
CREATE INDEX page_views_book_id_idx ON page_views (book_id);
CREATE INDEX page_views_viewed_at_idx ON page_views (viewed_at);

EXPLAIN (COSTS OFF)
SELECT view_id, customer_id
FROM page_views
WHERE book_id = 12
    AND viewed_at >= '2026-08-15 00:00:00+09'
    AND viewed_at < '2026-08-16 00:00:00+09';

EXPLAIN (COSTS OFF)
SELECT view_id, customer_id
FROM page_views
WHERE book_id = 12
    AND viewed_at >= '2026-06-01 00:00:00+09'
    AND viewed_at < '2026-09-01 00:00:00+09';
