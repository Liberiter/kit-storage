-- runner: reset
-- 11.3 따라 하기 1단계 — 항목이 딸린 주문은 지워지지 않는다 (오류 기대)
DELETE FROM orders WHERE order_id = 4;
