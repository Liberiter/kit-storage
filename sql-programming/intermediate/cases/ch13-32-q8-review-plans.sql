-- runner: reset
-- 13장(exit assessment) 문항 8 해설: 동료 질의의 계획(InitPlan과 본 질의에 Seq Scan + 식의 Filter 두 군데), 서울의 하루로 고친 질의(로그인 조회 수·로그인 방문자·창으로 얻은 비중)와 그 계획(Index Cond)
CREATE INDEX page_views_viewed_at_idx ON page_views (viewed_at);

CREATE VIEW daily_views AS
SELECT
    book_id,
    viewed_at::date AS day,
    count(*) AS views,
    count(DISTINCT customer_id) AS visitors
FROM page_views
GROUP BY book_id, viewed_at::date;

EXPLAIN (COSTS OFF)
SELECT
    *,
    round(100.0 * views / (
        SELECT sum(views) FROM daily_views WHERE day = '2026-08-15'
    ), 1) AS share
FROM daily_views
WHERE day = '2026-08-15'
ORDER BY views DESC
LIMIT 5;

SELECT
    book_id AS 도서번호,
    count(*) AS 조회수,
    count(customer_id) AS 로그인조회수,
    count(DISTINCT customer_id) AS 로그인방문자,
    round(100.0 * count(*) / sum(count(*)) OVER (), 1) AS "조회 비중(%)"
FROM page_views
WHERE viewed_at >= '2026-08-15 00:00:00+09'
    AND viewed_at < '2026-08-16 00:00:00+09'
GROUP BY book_id
ORDER BY 조회수 DESC, 도서번호
LIMIT 5;

EXPLAIN (COSTS OFF)
SELECT
    book_id AS 도서번호,
    count(*) AS 조회수,
    count(customer_id) AS 로그인조회수,
    count(DISTINCT customer_id) AS 로그인방문자,
    round(100.0 * count(*) / sum(count(*)) OVER (), 1) AS "조회 비중(%)"
FROM page_views
WHERE viewed_at >= '2026-08-15 00:00:00+09'
    AND viewed_at < '2026-08-16 00:00:00+09'
GROUP BY book_id
ORDER BY 조회수 DESC, 도서번호
LIMIT 5;
