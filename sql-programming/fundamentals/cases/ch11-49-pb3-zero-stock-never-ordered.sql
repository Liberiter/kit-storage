-- runner: reset
-- problem 3 해설 — 그 책들의 재고를 0으로 바꾸고 확인한다
UPDATE books
SET stock = 0
WHERE book_id NOT IN (SELECT book_id FROM order_items);

SELECT count(*) AS 권수, max(stock) AS 최고재고
FROM books
WHERE book_id NOT IN (SELECT book_id FROM order_items);
