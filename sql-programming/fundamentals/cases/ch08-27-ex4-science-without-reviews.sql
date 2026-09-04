-- exercise 4 해설: 리뷰가 하나도 없는 과학 분야 책 (LIMIT을 떼면 6행)
SELECT books.book_id, books.title, books.price
FROM books
LEFT JOIN reviews ON books.book_id = reviews.book_id
WHERE books.category = '과학' AND reviews.review_id IS NULL
ORDER BY books.book_id
LIMIT 5;
