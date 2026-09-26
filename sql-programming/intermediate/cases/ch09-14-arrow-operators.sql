-- 9장 9.2 «따라 하기» 1단계: -> 는 jsonb 를, ->> 는 글자를 꺼낸다. 없는 키는 널
SELECT
    view_id,
    context -> 'device' AS 기기jsonb,
    context ->> 'device' AS 기기글자,
    context ->> 'utm' AS 캠페인
FROM page_views
WHERE view_id IN (1, 11)
ORDER BY view_id;
