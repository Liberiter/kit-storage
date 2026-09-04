-- problem 1 해설: 별점 1~2점 리뷰를 최근 것부터 (BETWEEN + COALESCE + 조인)
SELECT
    reviews.review_id,
    books.title,
    reviews.rating,
    COALESCE(reviews.comment, '(내용 없음)') AS 리뷰내용
FROM reviews
INNER JOIN books ON reviews.book_id = books.book_id
WHERE reviews.rating BETWEEN 1 AND 2
ORDER BY reviews.review_date DESC, reviews.review_id
LIMIT 5;
