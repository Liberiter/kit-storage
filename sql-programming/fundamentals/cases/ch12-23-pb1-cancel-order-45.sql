-- runner: reset
-- problem 1 해설 — 재고 복구·항목 삭제·주문 삭제를 한 덩어리로
BEGIN;
UPDATE books SET stock = stock + 2 WHERE book_id IN (94, 154);
DELETE FROM order_items WHERE order_id = 45;
DELETE FROM orders WHERE order_id = 45;
COMMIT;

SELECT
    (SELECT stock FROM books WHERE book_id = 94) AS "94번 재고",
    (SELECT stock FROM books WHERE book_id = 154) AS "154번 재고",
    (SELECT count(*) FROM orders WHERE order_id = 45) AS "남은 주문",
    (SELECT count(*) FROM order_items WHERE order_id = 45) AS "남은 항목";
