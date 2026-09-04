-- 7.3 왜 그럴까요: 조인하기 전의 리뷰 여섯 줄 (301~303은 order_id가 널)
SELECT review_id, order_id, rating
FROM reviews
WHERE review_id BETWEEN 298 AND 303
ORDER BY review_id;
