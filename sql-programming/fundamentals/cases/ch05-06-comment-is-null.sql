-- 5.1 따라 하기 4단계 — reviews.comment의 NULL (별점만 남긴 리뷰)
SELECT review_id, book_id, rating, comment
FROM reviews
WHERE comment IS NULL
ORDER BY review_id
LIMIT 5;
