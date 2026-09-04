-- 7.3 따라 하기 2단계: 조건을 빼면 1,243행 전체가 짝을 찾는다 (앞 5줄)
SELECT order_items.order_id, books.title, order_items.quantity
FROM order_items
INNER JOIN books ON order_items.book_id = books.book_id
ORDER BY order_items.order_id, order_items.book_id
LIMIT 5;
