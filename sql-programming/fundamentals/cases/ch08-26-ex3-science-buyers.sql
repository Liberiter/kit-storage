-- exercise 3 해설: 과학 분야 책을 산 손님 (네 테이블. LIMIT을 떼면 119행)
SELECT customers.name, orders.order_date, books.title
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
INNER JOIN order_items ON orders.order_id = order_items.order_id
INNER JOIN books ON order_items.book_id = books.book_id
WHERE books.category = '과학'
ORDER BY orders.order_id, books.book_id
LIMIT 5;
