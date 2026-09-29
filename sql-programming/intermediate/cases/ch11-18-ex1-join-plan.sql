-- runner: reset
-- 11장 «연습하기» exercise 1 지문: 조인이 든 계획을 읽는다 — 어느 표를 통째로 읽고 어느 인덱스를 쓰는가
CREATE INDEX page_views_customer_id_idx ON page_views (customer_id);

EXPLAIN (COSTS OFF)
SELECT books.title, page_views.viewed_at
FROM page_views
INNER JOIN books ON page_views.book_id = books.book_id
WHERE page_views.customer_id = 7;
