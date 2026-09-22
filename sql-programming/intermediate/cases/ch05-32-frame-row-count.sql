-- 5장 5.3 «흔한 실수»: 프레임에 행이 모자라면 있는 만큼만 계산한다
WITH daily_views AS (
    SELECT CAST(viewed_at AS date) AS 날짜, count(*) AS 조회수
    FROM page_views
    WHERE CAST(viewed_at AS date) BETWEEN '2026-06-01' AND '2026-06-14'
    GROUP BY CAST(viewed_at AS date)
)
SELECT
    날짜,
    조회수,
    count(*) OVER (
        ORDER BY 날짜
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS "평균에 든 날 수",
    round(avg(조회수) OVER (
        ORDER BY 날짜
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )) AS "이레 평균"
FROM daily_views
ORDER BY 날짜;
