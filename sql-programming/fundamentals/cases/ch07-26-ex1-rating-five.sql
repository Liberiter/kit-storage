-- exercise 1 해설: 별점 5점 리뷰가 달린 책 (reviews ──> books)
SELECT reviews.review_id, books.title, books.author, reviews.rating
FROM reviews
INNER JOIN books ON reviews.book_id = books.book_id
WHERE reviews.rating = 5
ORDER BY reviews.review_id
LIMIT 5;
