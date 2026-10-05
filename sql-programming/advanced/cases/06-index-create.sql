-- runner: reset
-- kit smoke: 변경형 케이스 — 인덱스를 만들기 전과 뒤의 계획 (실행 전후로 world 를 되돌린다)
EXPLAIN (COSTS OFF) SELECT sale_id, sold_at FROM sales WHERE account_id = 4242;
CREATE INDEX sales_account_id_idx ON sales (account_id);
EXPLAIN (COSTS OFF) SELECT sale_id, sold_at FROM sales WHERE account_id = 4242;
