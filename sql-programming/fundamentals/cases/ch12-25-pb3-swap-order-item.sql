-- runner: reset
-- problem 3 해설 — 항목 교체와 두 책의 재고 조정을 한 덩어리로
BEGIN;
UPDATE order_items
SET book_id = 3, unit_price = 22500
WHERE order_id = 620 AND book_id = 106;
UPDATE books SET stock = stock + 2 WHERE book_id = 106;
UPDATE books SET stock = stock - 2 WHERE book_id = 3;
COMMIT;

SELECT
    order_items.book_id AS 도서번호,
    books.title AS 제목,
    order_items.quantity AS 수량,
    order_items.unit_price AS 단가,
    books.stock AS 재고
FROM order_items
INNER JOIN books ON order_items.book_id = books.book_id
WHERE order_items.order_id = 620
ORDER BY order_items.book_id;
