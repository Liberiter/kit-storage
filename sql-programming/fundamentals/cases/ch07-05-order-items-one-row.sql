-- 7.1 흔한 실수: 복합 기본키는 두 열이 함께 있어야 한 행을 집는다
SELECT order_id, book_id, quantity, unit_price
FROM order_items
WHERE order_id = 1 AND book_id = 176;
