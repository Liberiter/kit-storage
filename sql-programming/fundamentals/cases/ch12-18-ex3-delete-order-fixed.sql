-- runner: reset
-- exercise 3 해설 — 차례를 바로잡아 다시 실행한다
BEGIN;
DELETE FROM order_items WHERE order_id = 28;
DELETE FROM orders WHERE order_id = 28;
COMMIT;

SELECT
    (SELECT count(*) FROM orders WHERE order_id = 28) AS "남은 주문",
    (SELECT count(*) FROM order_items WHERE order_id = 28) AS "남은 항목",
    (SELECT count(*) FROM orders) AS "주문 수";
