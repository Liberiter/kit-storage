-- runner: reset
-- 복습 exercise 5(10장) 해설 — 서브쿼리로 고른 책의 재고를 0으로
BEGIN;
UPDATE books SET stock = 0 WHERE book_id NOT IN (SELECT book_id FROM reviews);

SELECT count(*) AS 권수, max(stock) AS 최고재고
FROM books
WHERE book_id NOT IN (SELECT book_id FROM reviews);

COMMIT;
