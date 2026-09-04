-- 5.2 왜 그럴까요 — 인자 순서를 뒤집으면 언제나 첫 인자가 나온다
SELECT review_id, COALESCE('(내용 없음)', comment) AS "리뷰 내용"
FROM reviews
ORDER BY review_id
LIMIT 4;
