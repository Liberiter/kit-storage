-- 5.2 따라 하기 2단계 — 별칭을 붙여 머리글을 고친다 (style.md R19)
SELECT review_id, rating, COALESCE(comment, '별점만 남겼습니다') AS "리뷰 내용"
FROM reviews
ORDER BY review_id
LIMIT 6;
