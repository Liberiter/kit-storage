-- exercise 1 해설 — 코멘트가 없는 리뷰를 최근 순으로 다섯 건
SELECT review_id AS 리뷰번호, rating AS 별점, review_date AS 리뷰날짜
FROM reviews
WHERE comment IS NULL
ORDER BY review_date DESC, review_id
LIMIT 5;
