-- runner: reset
-- 13장(exit assessment) 문항 8 지문: 동료가 만든 인덱스·뷰(조회 수·방문자 수)와 광복절 조회 상위 다섯 권·비중 질의 (점검 대상 — 서식 반례와 널을 세지 않는 열, 뷰를 두 번 부르는 서브쿼리를 일부러 담았다)
CREATE INDEX page_views_viewed_at_idx ON page_views (viewed_at);

CREATE VIEW daily_views AS
SELECT
    book_id,
    viewed_at::date AS day,
    count(*) AS views,
    count(DISTINCT customer_id) AS visitors
FROM page_views
GROUP BY book_id, viewed_at::date;

SELECT
    *,
    round(100.0 * views / (
        SELECT sum(views) FROM daily_views WHERE day = '2026-08-15'
    ), 1) AS share
FROM daily_views
WHERE day = '2026-08-15'
ORDER BY views DESC
LIMIT 5;
