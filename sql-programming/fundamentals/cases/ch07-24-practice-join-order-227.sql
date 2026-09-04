-- 7.3 practice 1 풀이: 주문 227번에 담긴 책 제목
SELECT order_items.order_id, books.title, order_items.quantity
FROM order_items
INNER JOIN books ON order_items.book_id = books.book_id
WHERE order_items.order_id = 227
ORDER BY order_items.book_id;
