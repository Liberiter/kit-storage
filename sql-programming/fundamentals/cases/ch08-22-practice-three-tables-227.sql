-- 8.2 practice 1 풀이: 주문 227번을 주문일·제목·수량과 함께 (세 테이블)
SELECT orders.order_id, orders.order_date, books.title, order_items.quantity
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
INNER JOIN books ON order_items.book_id = books.book_id
WHERE orders.order_id = 227
ORDER BY books.book_id;
