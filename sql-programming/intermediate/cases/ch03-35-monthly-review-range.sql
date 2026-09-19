-- 3장 «연습하기» exercise 1 해설: 달별 리뷰 수의 최소·최대·평균
WITH monthly_review AS (
    SELECT
        to_char(review_date, 'YYYY-MM') AS 리뷰월,
        count(*) AS 리뷰수
    FROM reviews
    WHERE review_date BETWEEN '2026-01-01' AND '2026-06-30'
    GROUP BY to_char(review_date, 'YYYY-MM')
)
SELECT
    min(리뷰수) AS 최소,
    max(리뷰수) AS 최대,
    round(avg(리뷰수), 1) AS 평균
FROM monthly_review;
