-- 9장 9.1 «따라 하기» 3단계: 서울 날짜로 다시 센 6월 1일까지의 조회 수 — 5월 31일이 사라진다
SELECT
    CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) AS 날짜,
    count(*) AS 조회수
FROM page_views
WHERE CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) <= '2026-06-01'
GROUP BY CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date)
ORDER BY 날짜;
