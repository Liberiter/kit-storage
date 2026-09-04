-- runner: reset
-- 11.1 따라 하기 5단계 — 없는 고객번호로 주문을 넣으면 막힌다 (오류 기대)
INSERT INTO orders (customer_id, order_date, status)
VALUES (9999, '2026-08-20', '배송준비');
