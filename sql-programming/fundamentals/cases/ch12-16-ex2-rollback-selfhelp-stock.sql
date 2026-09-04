-- runner: reset
-- exercise 2 해설 — 잘못 이해한 지시를 확정 전에 되돌린다
BEGIN;
UPDATE books SET stock = 50 WHERE category = '자기계발';

SELECT count(*) AS 권수, min(stock) AS 최저재고, max(stock) AS 최고재고
FROM books
WHERE category = '자기계발';

ROLLBACK;

SELECT count(*) AS 권수, min(stock) AS 최저재고, max(stock) AS 최고재고
FROM books
WHERE category = '자기계발';
