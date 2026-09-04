-- 5.2 practice 1 풀이 — 별점 1점 리뷰를 최신순으로, 코멘트를 채워서
SELECT review_id, rating, COALESCE(comment, '별점만 남겼습니다') AS "리뷰 내용"
FROM reviews
WHERE rating = 1
ORDER BY review_date DESC, review_id
LIMIT 5;
