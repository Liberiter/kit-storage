-- 워크로드 6 — 판매 기록 화면의 뒤쪽 페이지: 최근 것부터 정렬해 한참 뒤의 20건을 건너뛰어 읽는다 (5번).
SELECT sale_id, sold_at, store_id, quantity FROM sales ORDER BY sold_at DESC OFFSET 100000 LIMIT 20;
SELECT sale_id, sold_at, store_id, quantity FROM sales ORDER BY sold_at DESC OFFSET 200000 LIMIT 20;
SELECT sale_id, sold_at, store_id, quantity FROM sales ORDER BY sold_at DESC OFFSET 300000 LIMIT 20;
SELECT sale_id, sold_at, store_id, quantity FROM sales ORDER BY sold_at DESC OFFSET 400000 LIMIT 20;
SELECT sale_id, sold_at, store_id, quantity FROM sales ORDER BY sold_at DESC OFFSET 500000 LIMIT 20;
