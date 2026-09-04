-- runner: reset
-- 12.2 개념 — 서식 규칙 R47의 예제. 본문은 출력을 싣지 않는다
BEGIN;
UPDATE books SET price = price + 1000 WHERE category = '에세이';
ROLLBACK;
