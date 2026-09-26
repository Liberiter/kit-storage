-- 9장 9.2 «practice» 2: 캠페인 키가 있는 조회만 골라 캠페인별로 센다
SELECT context ->> 'utm' AS 캠페인, count(*) AS 조회수
FROM page_views
WHERE context ? 'utm'
GROUP BY context ->> 'utm'
ORDER BY 캠페인;
