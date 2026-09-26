-- 9장 9.1 «문제 상황»: 5장처럼 CAST(viewed_at AS date)로 센 날짜별 조회 수 — 5월 31일이 나온다.
-- 이어서 시각 차례로 첫 세 조회
SELECT CAST(viewed_at AS date) AS 날짜, count(*) AS 조회수
FROM page_views
WHERE CAST(viewed_at AS date) <= '2026-06-01'
GROUP BY CAST(viewed_at AS date)
ORDER BY 날짜;

SELECT view_id, viewed_at, client_tz FROM page_views ORDER BY viewed_at LIMIT 3;
