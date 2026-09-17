-- 1장 «도전하기» problem 2: 분야별 리뷰 성향
SELECT
    books.category AS 분야,
    count(*) AS 리뷰수,
    round(avg(reviews.rating), 2) AS 평균별점,
    count(*) FILTER (WHERE reviews.rating >= 4) AS 호평수,
    round(100.0 * count(*) FILTER (WHERE reviews.rating >= 4) / count(*), 1)
        AS "호평률(%)"
FROM books
INNER JOIN reviews ON books.book_id = reviews.book_id
GROUP BY books.category
ORDER BY "호평률(%)" DESC, 분야;
