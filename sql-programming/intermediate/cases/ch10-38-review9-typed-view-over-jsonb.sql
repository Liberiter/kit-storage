-- runner: reset
-- 10장 «복습 exercise» 3 해설 (9장): JSONB 속성을 타입 있는 열로 보이는 뷰
CREATE VIEW page_view_facts AS
SELECT
    view_id,
    book_id,
    CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) AS view_date,
    context ->> 'device' AS device,
    CAST(context ->> 'dwell_ms' AS integer) AS dwell_ms,
    CAST(context ->> 'scroll_pct' AS integer) AS scroll_pct
FROM page_views;

\d page_view_facts

SELECT
    device AS 기기,
    count(*) AS 조회수,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY dwell_ms) AS 체류중앙값,
    round(avg(scroll_pct), 1) AS 평균스크롤
FROM page_view_facts
WHERE view_date BETWEEN '2026-08-01' AND '2026-08-31'
GROUP BY device
ORDER BY 조회수 DESC;
