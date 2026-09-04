-- runner: reset
-- 12.2 따라 하기 2단계 — 확인하고 COMMIT으로 확정한다
BEGIN;
UPDATE books SET price = price + 1000 WHERE category = '에세이';

SELECT count(*) AS 권수, min(price) AS 최저가, max(price) AS 최고가
FROM books
WHERE category = '에세이';

COMMIT;

SELECT count(*) AS 권수, min(price) AS 최저가, max(price) AS 최고가
FROM books
WHERE category = '에세이';
