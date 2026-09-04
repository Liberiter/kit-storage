-- runner: reset
-- 12.2 따라 하기 3단계 — 확정한 뒤의 ROLLBACK은 되돌리지 못한다
BEGIN;
UPDATE books SET price = price + 1000 WHERE category = '에세이';
COMMIT;

ROLLBACK;

SELECT count(*) AS 권수, min(price) AS 최저가, max(price) AS 최고가
FROM books
WHERE category = '에세이';
