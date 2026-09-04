-- problem 2 해설: 어린이 분야 책을 산 손님·주문일·제목 (네 테이블. LIMIT을 떼면 138행)
SELECT customers.name, orders.order_id, orders.order_date, books.title
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
INNER JOIN order_items ON orders.order_id = order_items.order_id
INNER JOIN books ON order_items.book_id = books.book_id
WHERE books.category = '어린이'
ORDER BY orders.order_id, books.book_id
LIMIT 5;
