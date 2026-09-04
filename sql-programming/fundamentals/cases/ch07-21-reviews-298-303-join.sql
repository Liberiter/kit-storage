-- 7.3 왜 그럴까요: 같은 범위를 orders와 조인하면 널인 세 줄이 사라진다
SELECT reviews.review_id, reviews.order_id, orders.order_date, orders.status
FROM reviews
INNER JOIN orders ON reviews.order_id = orders.order_id
WHERE reviews.review_id BETWEEN 298 AND 303
ORDER BY reviews.review_id;
