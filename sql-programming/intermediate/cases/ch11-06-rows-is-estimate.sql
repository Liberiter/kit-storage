-- 11장 11.1 «흔한 실수»: 계획의 rows 는 어림이다 — 실제로 센 수와 견준다
EXPLAIN
SELECT view_id, viewed_at, book_id
FROM page_views
WHERE CAST(context ->> 'dwell_ms' AS integer) > 10000;

SELECT count(*) AS 조회수
FROM page_views
WHERE CAST(context ->> 'dwell_ms' AS integer) > 10000;
