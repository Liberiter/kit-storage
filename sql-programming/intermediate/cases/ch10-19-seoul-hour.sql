-- runner: reset
-- 10장 10.2 «practice» 1: 서울 시각의 「시」를 돌려주는 함수로 가장 붐비는 세 시간대
CREATE FUNCTION seoul_hour(moment timestamp with time zone)
RETURNS text
LANGUAGE sql
AS $$
SELECT to_char(moment AT TIME ZONE 'Asia/Seoul', 'HH24') AS 서울시;
$$;

SELECT seoul_hour(viewed_at) AS 서울시, count(*) AS 조회수
FROM page_views
GROUP BY seoul_hour(viewed_at)
ORDER BY 조회수 DESC
LIMIT 3;
