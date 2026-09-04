-- problem 1 해설 — 되돌릴 대상을 먼저 확인한다
SELECT
    order_items.book_id AS 도서번호,
    books.title AS 제목,
    order_items.quantity AS 수량,
    books.stock AS 재고
FROM order_items
INNER JOIN books ON order_items.book_id = books.book_id
WHERE order_items.order_id = 45
ORDER BY order_items.book_id;
