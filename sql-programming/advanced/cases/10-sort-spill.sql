-- kit smoke: 메모리를 넘는 정렬 — work_mem(4MB)을 넘는 정렬은 디스크로 넘친다. 병렬 계획을 끄고 시간·버퍼를 뺀다.
SET max_parallel_workers_per_gather = 0;
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF, BUFFERS OFF)
SELECT account_id, sold_at FROM sales ORDER BY account_id, sold_at LIMIT 100000 OFFSET 1000000;
