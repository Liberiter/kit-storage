-- 5.2 따라 하기 1단계 — COALESCE로 빈 자리를 채운다 (열 이름이 coalesce)
SELECT review_id, rating, COALESCE(comment, '별점만 남겼습니다')
FROM reviews
ORDER BY review_id
LIMIT 6;
