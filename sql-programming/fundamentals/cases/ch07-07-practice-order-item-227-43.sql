-- 7.1 practice 2 풀이: 복합 기본키 두 열로 주문 항목 한 행 집기
SELECT order_id, book_id, quantity, unit_price
FROM order_items
WHERE order_id = 227 AND book_id = 43;
