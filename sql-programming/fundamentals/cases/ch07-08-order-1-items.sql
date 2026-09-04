-- 7.2 문제 상황: order_items에는 도서번호만 있고 제목이 없다
SELECT order_id, book_id, quantity, unit_price
FROM order_items
WHERE order_id = 1
ORDER BY book_id;
