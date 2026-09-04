-- 8.2 따라 하기 4단계: 다중 조인을 전부 LEFT JOIN으로 이으면 조유나가 남는다
SELECT customers.customer_id, customers.name, orders.order_id, books.title
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
LEFT JOIN order_items ON orders.order_id = order_items.order_id
LEFT JOIN books ON order_items.book_id = books.book_id
WHERE customers.customer_id BETWEEN 6 AND 8
ORDER BY customers.customer_id, orders.order_id, books.book_id;
