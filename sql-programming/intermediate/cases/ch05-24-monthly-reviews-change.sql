-- 5장 5.2 «practice» 1: 월별 리뷰 수와 지난달 대비 증감
WITH monthly_reviews AS (
    SELECT
        to_char(review_date, 'YYYY-MM') AS 리뷰월,
        count(*) AS 리뷰수
    FROM reviews
    WHERE review_date BETWEEN '2026-01-01' AND '2026-06-30'
    GROUP BY to_char(review_date, 'YYYY-MM')
)
SELECT
    리뷰월,
    리뷰수,
    lag(리뷰수) OVER (ORDER BY 리뷰월) AS 전월리뷰수,
    리뷰수 - lag(리뷰수) OVER (ORDER BY 리뷰월) AS 증감
FROM monthly_reviews
ORDER BY 리뷰월;
