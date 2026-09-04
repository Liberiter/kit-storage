-- problem 3 (a): 주문과 조인해 놓고 order_id가 널인 리뷰를 찾으면 0행이다
SELECT reviews.review_id, reviews.rating, reviews.order_id
FROM reviews
INNER JOIN orders ON reviews.order_id = orders.order_id
WHERE reviews.order_id IS NULL
ORDER BY reviews.review_id
LIMIT 5;
