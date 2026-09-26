-- 9장 9.2 «흔한 실수» 1: ->> 로 꺼낸 값은 글자라 글자 차례로 비교된다
SELECT
    count(*) FILTER (WHERE context ->> 'dwell_ms' > '10000') AS 글자로비교,
    count(*) FILTER (WHERE CAST(context ->> 'dwell_ms' AS integer) > 10000)
        AS 수로비교
FROM page_views;
