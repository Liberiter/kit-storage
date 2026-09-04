-- runner: reset
-- exercise 4 해설 — 먼저 세고, 트랜잭션 안에서 확인한 뒤 확정한다
SELECT count(*) AS 대상권수 FROM books WHERE stock < 3;

BEGIN;
UPDATE books SET stock = 10 WHERE stock < 3;

SELECT count(*) AS 권수, min(stock) AS 최저재고 FROM books;

COMMIT;
