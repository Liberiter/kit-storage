-- runner: reset
-- 11장 11.2 «흔한 실수» 1: 열을 식으로 감싸면 viewed_at 인덱스가 있어도 Seq Scan
CREATE INDEX page_views_viewed_at_idx ON page_views (viewed_at);

EXPLAIN (COSTS OFF)
SELECT view_id, book_id
FROM page_views
WHERE CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) = '2026-08-15';

SELECT count(*) AS 조회수
FROM page_views
WHERE CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) = '2026-08-15';
