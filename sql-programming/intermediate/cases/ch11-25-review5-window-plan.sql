-- runner: reset
-- 11장 «복습 exercise» 2 해설 (5장): lag 가 든 질의의 계획 — WindowAgg 아래 Sort, 그 아래 Bitmap
CREATE INDEX page_views_book_id_idx ON page_views (book_id);

EXPLAIN (COSTS OFF)
SELECT
    view_id,
    viewed_at AS 조회시각,
    lag(viewed_at) OVER (ORDER BY viewed_at) AS 직전조회시각
FROM page_views
WHERE book_id = 12
ORDER BY viewed_at
LIMIT 5;

SELECT
    view_id,
    viewed_at AS 조회시각,
    lag(viewed_at) OVER (ORDER BY viewed_at) AS 직전조회시각
FROM page_views
WHERE book_id = 12
ORDER BY viewed_at
LIMIT 5;
