-- runner: reset
-- 11.3 따라 하기 2단계 — 딸린 항목부터 지우고 주문을 지운다
DELETE FROM order_items WHERE order_id = 4;
DELETE FROM orders WHERE order_id = 4;

SELECT count(*) AS 남은항목 FROM order_items WHERE order_id = 4;
SELECT count(*) AS 남은주문 FROM orders WHERE order_id = 4;
