-- runner: reset
-- exercise 3 지문 — 지우는 차례가 거꾸로라 막힌다 (오류 기대)
BEGIN;
DELETE FROM orders WHERE order_id = 28;
DELETE FROM order_items WHERE order_id = 28;
COMMIT;
