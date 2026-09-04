-- 8.1 practice 1 풀이: 리뷰가 하나도 달리지 않은 책 (LIMIT을 떼면 76행)
SELECT books.book_id, books.title, books.category
FROM books
LEFT JOIN reviews ON books.book_id = reviews.book_id
WHERE reviews.review_id IS NULL
ORDER BY books.book_id
LIMIT 5;
