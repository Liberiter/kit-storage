-- 4장 «복습 exercise» 1 해설 (2장 — 반조인): 리뷰 유무로 가른 가격 분포
WITH labeled AS (
    SELECT
        price,
        CASE
            WHEN EXISTS (
                SELECT 1 FROM reviews WHERE reviews.book_id = books.book_id
            ) THEN '리뷰 있음'
            ELSE '리뷰 없음'
        END AS 무리
    FROM books
)
SELECT
    무리,
    count(*) AS 권수,
    round(avg(price)) AS 평균가,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY price) AS 중앙값,
    round(stddev(price)) AS 표준편차
FROM labeled
GROUP BY 무리
ORDER BY 무리;
