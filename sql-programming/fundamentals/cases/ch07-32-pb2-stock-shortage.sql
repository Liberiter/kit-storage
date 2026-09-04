-- problem 2 해설: 재고보다 많이 주문된 항목 (WHERE에서 두 테이블의 열을 견준다)
SELECT order_items.order_id, books.title, order_items.quantity, books.stock
FROM order_items
INNER JOIN books ON order_items.book_id = books.book_id
WHERE books.stock < order_items.quantity
ORDER BY order_items.order_id, order_items.book_id
LIMIT 5;
