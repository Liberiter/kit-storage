-- runner: reset
-- 11장 11.2 «왜 그럴까요»: 인덱스가 있어도 고르는 줄이 많으면 Seq Scan
CREATE INDEX page_views_book_id_idx ON page_views (book_id);

EXPLAIN (COSTS OFF)
SELECT view_id, viewed_at, customer_id FROM page_views WHERE book_id <= 3;

EXPLAIN (COSTS OFF)
SELECT view_id, viewed_at, customer_id FROM page_views WHERE book_id <= 160;

SELECT
    count(*) FILTER (WHERE book_id <= 3) AS 세권까지,
    count(*) FILTER (WHERE book_id <= 160) AS 절반까지
FROM page_views;
