-- 7.3 흔한 실수: 여러 주문에 담긴 책 한 권은 조인 결과에서 여러 줄이 된다
SELECT order_items.order_id, order_items.quantity, books.title
FROM order_items
INNER JOIN books ON order_items.book_id = books.book_id
WHERE books.book_id = 29
ORDER BY order_items.order_id;
