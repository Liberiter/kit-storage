-- 7.2 왜 그럴까요: 외래키 열에도 널이 올 수 있다 (구매 인증이 없는 리뷰)
SELECT review_id, book_id, order_id, rating
FROM reviews
WHERE order_id IS NULL
ORDER BY review_id
LIMIT 5;
