-- 8.2 따라 하기 2단계: customers를 앞에 붙여 네 테이블을 잇는다
-- (부산 손님이 산 책. LIMIT을 떼면 134행)
SELECT customers.name, orders.order_date, books.title, order_items.quantity
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
INNER JOIN order_items ON orders.order_id = order_items.order_id
INNER JOIN books ON order_items.book_id = books.book_id
WHERE customers.city = '부산'
ORDER BY orders.order_id, books.book_id
LIMIT 5;
