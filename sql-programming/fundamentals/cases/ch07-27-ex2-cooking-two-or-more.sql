-- exercise 2 해설: 요리 분야 책을 2권 이상 담은 주문 항목 (3장 AND)
SELECT order_items.order_id, books.title, order_items.quantity
FROM order_items
INNER JOIN books ON order_items.book_id = books.book_id
WHERE books.category = '요리' AND order_items.quantity >= 2
ORDER BY order_items.order_id
LIMIT 5;
