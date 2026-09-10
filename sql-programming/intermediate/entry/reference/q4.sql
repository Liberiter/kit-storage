-- 입장 점검 문항 4 참조 해답 (entry_check.sh --reference 가 쓴다)
BEGIN;
INSERT INTO orders (customer_id, order_date, status)
VALUES (3, '2026-09-01', '배송준비');
INSERT INTO order_items (order_id, book_id, quantity, unit_price)
SELECT max(order_id), 7, 2, (SELECT price FROM books WHERE book_id = 7)
FROM orders;
UPDATE books SET stock = stock - 2 WHERE book_id = 7;
COMMIT;
