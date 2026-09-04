-- 5.2 흔한 실수 — 빈 문자열로 채우면 화면에서는 채우기 전과 구별되지 않는다
SELECT review_id, rating, COALESCE(comment, '') AS "리뷰 내용"
FROM reviews
ORDER BY review_id
LIMIT 6;
