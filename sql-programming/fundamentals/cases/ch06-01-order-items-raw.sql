-- 6.1 문제 상황: order_items에는 금액 열이 없다
SELECT order_id, book_id, quantity, unit_price
FROM order_items
ORDER BY order_id, book_id
LIMIT 5;
