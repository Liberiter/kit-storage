-- runner: reset
-- 11장 11.2 «따라 하기» 3단계: \d 의 Indexes: 줄에 새 인덱스, DROP INDEX 뒤에는 다시 Seq Scan
CREATE INDEX page_views_book_id_idx ON page_views (book_id);

\d page_views

DROP INDEX page_views_book_id_idx;

EXPLAIN (COSTS OFF)
SELECT view_id, viewed_at, customer_id FROM page_views WHERE book_id = 12;
