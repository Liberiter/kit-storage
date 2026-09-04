-- runner: reset
-- 12.1 따라 하기 2단계 — 도서번호를 잘못 적어 세 번째 문장이 막힌다 (오류 기대)
BEGIN;
UPDATE books SET stock = stock - 1 WHERE book_id = 1;
INSERT INTO orders (customer_id, order_date, status)
VALUES (1, '2026-08-25', '배송준비');
INSERT INTO order_items (order_id, book_id, quantity, unit_price)
VALUES ((SELECT max(order_id) FROM orders), 99999, 1, 29500);
COMMIT;
