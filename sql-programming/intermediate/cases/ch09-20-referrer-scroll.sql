-- 9장 9.2 «practice» 1: 유입 경로별 조회 수와 평균 스크롤 비율
SELECT
    context ->> 'referrer' AS 유입경로,
    count(*) AS 조회수,
    round(avg(CAST(context ->> 'scroll_pct' AS integer)), 1) AS 평균스크롤
FROM page_views
GROUP BY context ->> 'referrer'
ORDER BY 조회수 DESC;
