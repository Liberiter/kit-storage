-- runner: reset
-- 11장 «도전하기» problem 2 해설: client_tz 인덱스 — 드문 값은 인덱스, 흔한 값은 Seq Scan
CREATE INDEX page_views_client_tz_idx ON page_views (client_tz);

EXPLAIN (COSTS OFF)
SELECT view_id, book_id FROM page_views WHERE client_tz = 'Europe/London';

EXPLAIN (COSTS OFF)
SELECT view_id, book_id FROM page_views WHERE client_tz = 'Asia/Seoul';

SELECT client_tz AS 방문자시간대, count(*) AS 조회수
FROM page_views
GROUP BY client_tz
ORDER BY 조회수 DESC;
