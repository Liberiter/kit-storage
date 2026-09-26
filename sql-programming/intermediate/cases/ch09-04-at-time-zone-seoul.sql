-- 9장 9.1 «따라 하기» 2단계: AT TIME ZONE 으로 서울의 벽시계 시각과 서울 날짜를 꺼낸다
SELECT
    view_id,
    viewed_at,
    viewed_at AT TIME ZONE 'Asia/Seoul' AS 서울시각,
    CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) AS 서울날짜
FROM page_views
WHERE view_id = 4;
