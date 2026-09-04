-- 5.1 practice 2 풀이 — 별점 5점인데 코멘트가 없는 리뷰
SELECT review_id, rating, comment
FROM reviews
WHERE comment IS NULL AND rating = 5
ORDER BY review_id
LIMIT 5;
