-- runner: reset
-- 11장 «도전하기» problem 1 해설: 함수를 조건에서 걷고 viewed_at 범위로 — Index Scan, 다섯 줄은 지문과 같다
CREATE INDEX page_views_viewed_at_idx ON page_views (viewed_at);

EXPLAIN (COSTS OFF)
SELECT book_id, count(*) AS 조회수
FROM page_views
WHERE viewed_at >= '2026-08-31 00:00:00+09'
    AND viewed_at < '2026-09-01 00:00:00+09'
GROUP BY book_id
ORDER BY 조회수 DESC, book_id
LIMIT 5;

SELECT book_id, count(*) AS 조회수
FROM page_views
WHERE viewed_at >= '2026-08-31 00:00:00+09'
    AND viewed_at < '2026-09-01 00:00:00+09'
GROUP BY book_id
ORDER BY 조회수 DESC, book_id
LIMIT 5;
