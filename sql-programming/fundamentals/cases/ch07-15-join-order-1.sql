-- 7.3 따라 하기 1단계: order_items와 books를 조인해 주문 1번의 제목을 함께 본다
SELECT order_items.order_id, books.title, order_items.quantity
FROM order_items
INNER JOIN books ON order_items.book_id = books.book_id
WHERE order_items.order_id = 1
ORDER BY order_items.book_id;
