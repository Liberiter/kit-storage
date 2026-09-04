-- 8.2 따라 하기 3단계: 다른 경로로 세 테이블을 잇는다 (reviews가 가운데)
-- (별점 5점 리뷰. LIMIT을 떼면 160행)
SELECT reviews.review_id, customers.name, books.title, reviews.rating
FROM reviews
INNER JOIN books ON reviews.book_id = books.book_id
INNER JOIN customers ON reviews.customer_id = customers.customer_id
WHERE reviews.rating = 5
ORDER BY reviews.review_id
LIMIT 5;
