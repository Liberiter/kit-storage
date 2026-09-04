-- problem 3 (b)(c) 해설 — IS NULL로 고친 질의 (앞 다섯 건)
SELECT review_id, rating, comment
FROM reviews
WHERE comment IS NULL
ORDER BY review_id
LIMIT 5;
