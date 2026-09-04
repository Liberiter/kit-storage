-- runner: reset
-- exercise 1 해설 — 확정하기 전에 확인하고 나서 확정한다
BEGIN;
UPDATE books SET stock = stock - 2 WHERE book_id = 3;
INSERT INTO orders (customer_id, order_date, status)
VALUES (2, '2026-08-26', '배송준비');
INSERT INTO order_items (order_id, book_id, quantity, unit_price)
VALUES ((SELECT max(order_id) FROM orders), 3, 2, 22500);

SELECT
    (SELECT stock FROM books WHERE book_id = 3) AS "3번 책 재고",
    (SELECT count(*) FROM orders) AS "주문 수",
    (SELECT count(*) FROM order_items) AS "항목 수";

COMMIT;
