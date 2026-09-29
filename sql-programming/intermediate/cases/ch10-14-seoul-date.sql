-- runner: reset
-- 10장 10.2 «따라 하기» 3단계: 9장의 서울 날짜 식을 함수 seoul_date 로
CREATE FUNCTION seoul_date(moment timestamp with time zone)
RETURNS date
LANGUAGE sql
AS $$
SELECT CAST(moment AT TIME ZONE 'Asia/Seoul' AS date) AS 서울날짜;
$$;

SELECT seoul_date(viewed_at) AS 날짜, count(*) AS 조회수
FROM page_views
WHERE viewed_at >= '2026-06-01 00:00:00+09'
    AND viewed_at < '2026-06-04 00:00:00+09'
GROUP BY seoul_date(viewed_at)
ORDER BY 날짜;
