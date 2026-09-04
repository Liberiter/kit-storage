-- runner: reset
-- 11.2 흔한 실수 — SET의 대입을 AND로 이으면 오류다 (오류 기대)
UPDATE books SET price = 17500 AND stock = 25 WHERE book_id = 8;
