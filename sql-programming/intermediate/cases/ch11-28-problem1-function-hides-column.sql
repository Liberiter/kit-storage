-- runner: reset
-- 11장 «도전하기» problem 1 지문: 10장의 함수 seoul_date 로 거른 대시보드 질의 — 인덱스가 있는데 Seq Scan
CREATE INDEX page_views_viewed_at_idx ON page_views (viewed_at);

CREATE FUNCTION seoul_date(moment timestamp with time zone)
RETURNS date
LANGUAGE sql
AS $$
SELECT CAST(moment AT TIME ZONE 'Asia/Seoul' AS date) AS 서울날짜;
$$;

EXPLAIN (COSTS OFF)
SELECT book_id, count(*) AS 조회수
FROM page_views
WHERE seoul_date(viewed_at) = '2026-08-31'
GROUP BY book_id
ORDER BY 조회수 DESC, book_id
LIMIT 5;

SELECT book_id, count(*) AS 조회수
FROM page_views
WHERE seoul_date(viewed_at) = '2026-08-31'
GROUP BY book_id
ORDER BY 조회수 DESC, book_id
LIMIT 5;
