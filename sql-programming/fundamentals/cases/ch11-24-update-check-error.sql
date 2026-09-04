-- runner: reset
-- 11.2 왜 그럴까요 — CHECK 제약은 UPDATE도 막는다 (오류 기대)
UPDATE books SET stock = -1 WHERE book_id = 8;
