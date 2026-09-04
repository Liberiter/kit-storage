-- exercise 2 해설: 별점 1~2점 리뷰를 쓴 손님과 그 책 (세 테이블. LIMIT을 떼면 77행)
SELECT reviews.review_id, customers.name, books.title, reviews.rating
FROM reviews
INNER JOIN books ON reviews.book_id = books.book_id
INNER JOIN customers ON reviews.customer_id = customers.customer_id
WHERE reviews.rating BETWEEN 1 AND 2
ORDER BY reviews.review_id
LIMIT 5;
