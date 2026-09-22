-- 5장 5.3 «따라 하기» 1단계: 창에 ORDER BY 를 넣으면 합계가 누적으로 바뀐다
WITH daily_views AS (
    SELECT CAST(viewed_at AS date) AS 날짜, count(*) AS 조회수
    FROM page_views
    WHERE CAST(viewed_at AS date) BETWEEN '2026-06-01' AND '2026-06-14'
    GROUP BY CAST(viewed_at AS date)
)
SELECT
    날짜,
    조회수,
    sum(조회수) OVER () AS "기간 합계",
    sum(조회수) OVER (ORDER BY 날짜) AS "누적 조회수"
FROM daily_views
ORDER BY 날짜;
