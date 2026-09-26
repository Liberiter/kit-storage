-- 9장 9.2 «따라 하기» 3단계: 키가 있는가(?)와 이름·값 짝을 담고 있는가(@>)
SELECT
    count(*) FILTER (WHERE context ? 'utm') AS 캠페인있음,
    count(*) FILTER (WHERE context ->> 'referrer' = 'ad') AS 광고유입
FROM page_views;

SELECT count(*) AS 태블릿광고
FROM page_views
WHERE context @> '{"device": "tablet", "referrer": "ad"}';
