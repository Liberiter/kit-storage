-- 5장 5.3 «따라 하기» 3단계: 프레임의 끝을 뒤로 넘겨 앞뒤를 함께 본다
WITH daily_views AS (
    SELECT CAST(viewed_at AS date) AS 날짜, count(*) AS 조회수
    FROM page_views
    WHERE CAST(viewed_at AS date) BETWEEN '2026-06-01' AND '2026-06-14'
    GROUP BY CAST(viewed_at AS date)
)
SELECT
    날짜,
    조회수,
    round(avg(조회수) OVER (
        ORDER BY 날짜
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    )) AS "사흘 평균"
FROM daily_views
ORDER BY 날짜;
