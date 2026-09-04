-- 5.2 따라 하기 4단계 — 3·4장의 절과 함께 쓴 완성형 질의
SELECT review_id, rating, COALESCE(comment, '별점만 남겼습니다') AS "리뷰 내용"
FROM reviews
WHERE rating = 5
ORDER BY review_date DESC, review_id
LIMIT 5;
