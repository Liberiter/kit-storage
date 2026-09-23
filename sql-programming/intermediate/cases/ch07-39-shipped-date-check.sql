-- runner: reset
-- 7장 «연습하기» exercise 2 해설: orders 의 표 수준 CHECK 가 막는 것 (오류 기대)
INSERT INTO orders (customer_id, order_date, status, shipped_date)
VALUES (1, '2026-09-08', '배송완료', NULL);
