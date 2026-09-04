-- runner: reset
-- 12.1 따라 하기 1단계 — 세 문장을 한 덩어리로 묶어 확정한다
BEGIN;
UPDATE books SET stock = stock - 1 WHERE book_id = 1;
INSERT INTO orders (customer_id, order_date, status)
VALUES (1, '2026-08-25', '배송준비');
INSERT INTO order_items (order_id, book_id, quantity, unit_price)
VALUES ((SELECT max(order_id) FROM orders), 1, 1, 29500);
COMMIT;

SELECT
    (SELECT stock FROM books WHERE book_id = 1) AS "1번 책 재고",
    (SELECT count(*) FROM orders) AS "주문 수",
    (SELECT count(*) FROM order_items) AS "항목 수";
