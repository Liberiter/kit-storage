-- runner: reset
-- 12.1 개념 — 서식 규칙 R45·R46의 예제. 본문은 출력을 싣지 않는다
BEGIN;
UPDATE books SET stock = stock - 1 WHERE book_id = 1;
UPDATE books SET stock = stock + 1 WHERE book_id = 2;
COMMIT;
