-- 8.2 왜 그럴까요: 아직 이어 붙이지 않은 테이블을 ON에서 참조하면 오류다
SELECT customers.name, books.title
FROM customers
INNER JOIN books ON order_items.book_id = books.book_id
INNER JOIN orders ON customers.customer_id = orders.customer_id
INNER JOIN order_items ON orders.order_id = order_items.order_id
LIMIT 3;
