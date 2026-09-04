-- 13장 exit assessment 문항 10 해설: 별점 5점 리뷰와 구매 인증 주문일
SELECT
    reviews.review_id AS 리뷰번호,
    books.title AS 제목,
    reviews.review_date AS 리뷰일,
    orders.order_date AS 주문일
FROM reviews
INNER JOIN books ON reviews.book_id = books.book_id
LEFT JOIN orders ON reviews.order_id = orders.order_id
WHERE reviews.rating = 5 AND reviews.review_date >= '2026-08-13'
ORDER BY reviews.review_date, reviews.review_id;
