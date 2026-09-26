-- 9장 9.1 «따라 하기» 4단계: 시간대를 열로 넘겨 방문자마다의 현지 시각을 꺼낸다
SELECT
    view_id,
    client_tz,
    viewed_at AT TIME ZONE 'Asia/Seoul' AS 서울시각,
    viewed_at AT TIME ZONE client_tz AS 현지시각
FROM page_views
WHERE view_id IN (1, 4, 7, 9)
ORDER BY view_id;
