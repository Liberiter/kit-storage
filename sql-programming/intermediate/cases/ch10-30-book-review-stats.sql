-- runner: reset
-- 10장 «연습하기» exercise 1 해설: 책마다 리뷰 수와 평균 별점을 담은 뷰
CREATE VIEW book_review_stats AS
SELECT
    books.book_id,
    books.title,
    count(reviews.review_id) AS review_count,
    round(avg(reviews.rating), 2) AS avg_rating
FROM books
LEFT JOIN reviews ON books.book_id = reviews.book_id
GROUP BY books.book_id, books.title;

SELECT title AS 제목, review_count AS 리뷰수, avg_rating AS 평균별점
FROM book_review_stats
WHERE review_count >= 5
ORDER BY avg_rating DESC, book_id
LIMIT 5;
