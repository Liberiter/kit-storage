-- smoke: JSONB 추출값의 분포 통계, 배열 포함 검사, 시간대 변환 (9장·4장 요구 예시)
SELECT context->>'device' AS device,
       count(*) AS views,
       percentile_cont(0.5) WITHIN GROUP (ORDER BY (context->>'dwell_ms')::int) AS median_dwell_ms,
       round(stddev((context->>'dwell_ms')::int)) AS stddev_dwell_ms
FROM page_views
GROUP BY context->>'device'
ORDER BY views DESC;

SELECT count(*) AS books_tagged_bestseller
FROM book_meta
WHERE tags @> ARRAY['베스트셀러'];

SELECT view_id,
       viewed_at,
       client_tz,
       viewed_at AT TIME ZONE client_tz AS local_time
FROM page_views
WHERE client_tz <> 'Asia/Seoul'
ORDER BY view_id
LIMIT 3;
