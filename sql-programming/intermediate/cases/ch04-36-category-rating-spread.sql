-- 4장 «연습하기» exercise 1 해설: 분야별 별점의 가운데와 퍼짐
SELECT
    books.category AS 분야,
    count(*) AS 리뷰수,
    round(avg(reviews.rating), 2) AS 평균별점,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY reviews.rating) AS 중앙값,
    round(stddev(reviews.rating), 2) AS 표준편차
FROM reviews
INNER JOIN books ON reviews.book_id = books.book_id
GROUP BY books.category
ORDER BY 평균별점 DESC, 분야;
