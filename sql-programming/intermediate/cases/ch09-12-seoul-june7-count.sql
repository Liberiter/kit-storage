-- 9장 9.1 «practice» 2: 서울 날짜 6월 7일 하루의 조회 수
SELECT count(*) AS 조회수
FROM page_views
WHERE viewed_at >= '2026-06-07 00:00:00+09'
    AND viewed_at < '2026-06-08 00:00:00+09';
