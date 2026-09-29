-- runner: reset
-- 11장 11.2 «practice» 1: customer_id 에 인덱스 — 11.1 practice 2 의 Parallel Seq Scan 이 Bitmap 으로
CREATE INDEX page_views_customer_id_idx ON page_views (customer_id);

EXPLAIN (COSTS OFF)
SELECT view_id, viewed_at FROM page_views WHERE customer_id = 7;
