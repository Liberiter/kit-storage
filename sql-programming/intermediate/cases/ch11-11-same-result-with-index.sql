-- runner: reset
-- 11장 11.2 «따라 하기» 2단계: 문제 상황의 질의 — 계획은 바뀌고 결과는 그대로다
CREATE INDEX page_views_book_id_idx ON page_views (book_id);

EXPLAIN (COSTS OFF)
SELECT view_id, viewed_at, customer_id
FROM page_views
WHERE book_id = 12
ORDER BY viewed_at DESC
LIMIT 5;

SELECT view_id, viewed_at, customer_id
FROM page_views
WHERE book_id = 12
ORDER BY viewed_at DESC
LIMIT 5;
