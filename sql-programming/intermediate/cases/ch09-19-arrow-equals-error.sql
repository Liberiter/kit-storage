-- 9장 9.2 «흔한 실수» 2: -> 로 꺼낸 jsonb 를 글자와 견주면 그 글자를 JSON 으로 읽으려다 막힌다
SELECT count(*) AS 모바일 FROM page_views WHERE context -> 'device' = 'mobile';
