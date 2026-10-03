-- runner: reset
-- 12장 도전하기 problem 2 해설: 동료의 조회 수 질의와 고친 질의의 계획, 고친 질의의 수, 식으로 더하는 한 문장
CREATE INDEX page_views_viewed_at_idx ON page_views (viewed_at);

EXPLAIN (COSTS OFF)
SELECT count(*) AS 어제조회수
FROM page_views
WHERE book_id = 12
    AND CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) = '2026-08-31';

EXPLAIN (COSTS OFF)
SELECT count(*) AS 어제조회수
FROM page_views
WHERE book_id = 12
    AND viewed_at >= '2026-08-31 00:00:00+09'
    AND viewed_at < '2026-09-01 00:00:00+09';

SELECT count(*) AS 어제조회수
FROM page_views
WHERE book_id = 12
    AND viewed_at >= '2026-08-31 00:00:00+09'
    AND viewed_at < '2026-09-01 00:00:00+09';

UPDATE books SET stock = stock + 10 WHERE book_id = 12 RETURNING book_id, stock;
