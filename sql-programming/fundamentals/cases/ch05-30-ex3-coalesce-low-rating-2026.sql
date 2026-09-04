-- exercise 3 해설 — 2026년의 별점 3점 이하 리뷰를 채워서 최신순으로
SELECT review_id, rating, COALESCE(comment, '(내용 없음)') AS "리뷰 내용"
FROM reviews
WHERE rating <= 3 AND review_date >= '2026-01-01'
ORDER BY review_date DESC, review_id
LIMIT 5;
