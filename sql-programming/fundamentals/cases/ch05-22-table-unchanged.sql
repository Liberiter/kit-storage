-- 5.2 왜 그럴까요 — COALESCE는 표시만 바꾼다. 테이블의 comment는 여전히 NULL
SELECT review_id, comment
FROM reviews
WHERE comment IS NULL
ORDER BY review_id
LIMIT 3;
