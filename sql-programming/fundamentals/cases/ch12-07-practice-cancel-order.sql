-- runner: reset
-- 12.1 practice 2 풀이 — 항목 삭제와 주문 삭제를 한 덩어리로
BEGIN;
DELETE FROM order_items WHERE order_id = 4;
DELETE FROM orders WHERE order_id = 4;
COMMIT;

SELECT
    (SELECT count(*) FROM orders WHERE order_id = 4) AS "남은 주문",
    (SELECT count(*) FROM order_items WHERE order_id = 4) AS "남은 항목";
