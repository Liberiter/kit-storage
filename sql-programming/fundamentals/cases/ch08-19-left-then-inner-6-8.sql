-- 8.2 왜 그럴까요: LEFT JOIN 뒤에 INNER JOIN을 이으면 널 행이 다시 버려진다
-- (따라 하기 4단계의 여덟 줄에서 조유나 한 줄이 빠져 일곱 줄이 된다)
SELECT customers.customer_id, customers.name, orders.order_id, books.title
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
INNER JOIN order_items ON orders.order_id = order_items.order_id
INNER JOIN books ON order_items.book_id = books.book_id
WHERE customers.customer_id BETWEEN 6 AND 8
ORDER BY customers.customer_id, orders.order_id, books.book_id;
