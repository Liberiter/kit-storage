-- runner: reset
-- 9장 9.3 «왜 그럴까요»: 배열 칸은 원소가 무엇이든 받는다 — 오타 태그 「교앙」이 그대로 들어간다
UPDATE book_meta
SET tags = tags || ARRAY['교앙']
WHERE book_id = 1
RETURNING book_id, NEW.tags AS 바뀐태그;
