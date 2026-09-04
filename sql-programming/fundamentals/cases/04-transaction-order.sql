-- runner: reset
-- smoke: 변경형 케이스 — 이체형 시나리오 (재고 차감 + 주문 생성, 12장 전제)
BEGIN;
UPDATE books SET stock = stock - 1 WHERE book_id = 1;
INSERT INTO orders (customer_id, order_date, status)
VALUES (1, '2026-08-24', '배송준비');
INSERT INTO order_items (order_id, book_id, quantity, unit_price)
SELECT max(order_id), 1, 1, (SELECT price FROM books WHERE book_id = 1)
  FROM orders;
COMMIT;

SELECT b.stock,
       (SELECT count(*) FROM orders WHERE order_date = '2026-08-24') AS new_orders
  FROM books b WHERE b.book_id = 1;
