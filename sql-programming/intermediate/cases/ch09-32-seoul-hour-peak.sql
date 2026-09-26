-- 9장 «연습하기» exercise 1 해설: 서울 시각으로 조회가 가장 많은 세 시간대, 그리고 변환 없이 센 것
SELECT
    to_char(viewed_at AT TIME ZONE 'Asia/Seoul', 'HH24') AS 서울시,
    count(*) AS 조회수
FROM page_views
GROUP BY to_char(viewed_at AT TIME ZONE 'Asia/Seoul', 'HH24')
ORDER BY 조회수 DESC
LIMIT 3;

SELECT to_char(viewed_at, 'HH24') AS 세션시, count(*) AS 조회수
FROM page_views
GROUP BY to_char(viewed_at, 'HH24')
ORDER BY 조회수 DESC
LIMIT 3;
