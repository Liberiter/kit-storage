-- 11장 11.1 «practice» 2: 인덱스가 없는 customer_id 조건 — Gather 아래 Parallel Seq Scan
EXPLAIN (COSTS OFF)
SELECT view_id, viewed_at FROM page_views WHERE customer_id = 7;
