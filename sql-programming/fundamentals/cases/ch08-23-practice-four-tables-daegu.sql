-- 8.2 practice 2 풀이: 대구 손님이 산 책 (네 테이블. LIMIT을 떼면 125행)
SELECT customers.name, orders.order_date, books.title, order_items.quantity
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
INNER JOIN order_items ON orders.order_id = order_items.order_id
INNER JOIN books ON order_items.book_id = books.book_id
WHERE customers.city = '대구'
ORDER BY orders.order_id, books.book_id
LIMIT 5;
