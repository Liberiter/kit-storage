-- problem 2 해설 — 별점 4점 이상 리뷰를 빈칸 없이 인쇄용으로
SELECT
    review_id AS 리뷰번호,
    rating AS 별점,
    COALESCE(comment, '별점만 남긴 리뷰입니다') AS "리뷰 내용"
FROM reviews
WHERE rating >= 4
ORDER BY review_date DESC, review_id
LIMIT 5;
