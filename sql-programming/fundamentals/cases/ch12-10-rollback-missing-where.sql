-- runner: reset
-- 12.2 따라 하기 1단계 — WHERE를 빠뜨린 UPDATE를 확정 전에 되돌린다
BEGIN;
UPDATE books SET price = price + 1000;

SELECT count(*) AS 권수, min(price) AS 최저가, max(price) AS 최고가 FROM books;

ROLLBACK;

SELECT count(*) AS 권수, min(price) AS 최저가, max(price) AS 최고가 FROM books;
