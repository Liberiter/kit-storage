-- kit smoke: 통계와 실제가 어긋나는 자리 — 서로 독립이 아닌 두 열(city·district)을 함께 거르면 추정 행 수가
-- 실제보다 작다. 병렬 계획을 끄고 시간·버퍼를 빼서 출력이 실행마다 같게 한다.
SET max_parallel_workers_per_gather = 0;
EXPLAIN (ANALYZE, TIMING OFF, SUMMARY OFF, BUFFERS OFF)
SELECT * FROM accounts WHERE city = '서울' AND district = '강남구';
