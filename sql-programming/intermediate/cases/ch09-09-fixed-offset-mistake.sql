-- 9장 9.1 «흔한 실수» 1: 시차를 더하면 다른 순간이 된다, 고정 시차로는 날짜까지 틀린다
SELECT
    view_id,
    viewed_at + CAST('9 hours' AS interval) AS 아홉시간더함,
    viewed_at AT TIME ZONE 'Asia/Seoul' AS 서울시각
FROM page_views
WHERE view_id = 4;

SELECT
    view_id,
    CAST(viewed_at - CAST('8 hours' AS interval) AS date) AS 여덟시간뺀날짜,
    CAST(viewed_at AT TIME ZONE client_tz AS date) AS 현지날짜
FROM page_views
WHERE view_id = 9;
