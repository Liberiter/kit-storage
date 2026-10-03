-- runner: reset
-- 12장 «연습하기» exercise 2 해설: 재고가 남아 있을 때만 줄이는 문장을 두 번 — 두 번째는 0행
UPDATE books
SET stock = stock - 1
WHERE book_id = 6 AND stock >= 1
RETURNING book_id, stock;

UPDATE books
SET stock = stock - 1
WHERE book_id = 6 AND stock >= 1
RETURNING book_id, stock;
