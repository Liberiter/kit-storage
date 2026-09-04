-- runner: reset
-- 12.1 practice 1 풀이 — 다른 손님·다른 책으로 주문 접수를 묶는다
BEGIN;
UPDATE books SET stock = stock - 2 WHERE book_id = 100;
INSERT INTO orders (customer_id, order_date, status)
VALUES (2, '2026-08-26', '배송준비');
INSERT INTO order_items (order_id, book_id, quantity, unit_price)
VALUES ((SELECT max(order_id) FROM orders), 100, 2, 28500);
COMMIT;

SELECT
    (SELECT stock FROM books WHERE book_id = 100) AS "100번 책 재고",
    (SELECT count(*) FROM orders) AS "주문 수",
    (SELECT count(*) FROM order_items) AS "항목 수";
