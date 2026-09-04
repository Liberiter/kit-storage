-- 8.2 문제 상황: 두 테이블만 이으면 제목은 나오지만 누가 샀는지는 알 수 없다
SELECT order_items.order_id, books.title, order_items.quantity
FROM order_items
INNER JOIN books ON order_items.book_id = books.book_id
WHERE order_items.order_id = 5
ORDER BY order_items.book_id;
