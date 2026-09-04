-- 복습 exercise 해설 (3·5장): 제목 LIKE + 별점 비교 + COALESCE
SELECT
    reviews.review_id,
    books.title,
    reviews.rating,
    COALESCE(reviews.comment, '(별점만)') AS 리뷰내용
FROM reviews
INNER JOIN books ON reviews.book_id = books.book_id
WHERE books.title LIKE '%여행%' AND reviews.rating >= 4
ORDER BY reviews.review_id
LIMIT 5;
