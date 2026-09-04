-- 8.2 흔한 실수: 엉뚱한 열끼리 이으면 오류 없이 뜻 없는 결과가 나온다
-- (order_id와 book_id를 이었다)
SELECT orders.order_id, order_items.book_id, books.title
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.book_id
INNER JOIN books ON order_items.book_id = books.book_id
ORDER BY orders.order_id, order_items.book_id
LIMIT 3;
