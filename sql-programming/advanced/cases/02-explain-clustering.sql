-- kit smoke: 실행 계획 케이스 — 행은 같고 적재 차례만 다른 두 테이블에서 같은 범위 질의의 계획이 갈린다
-- (발송 시각 인덱스는 두 테이블에 같은 정의로 있다). 통계를 전체 행으로 받았으므로 계획이 구축마다 같다.
EXPLAIN (COSTS OFF)
SELECT count(*), sum(weight_g) FROM shipments_sorted
 WHERE shipped_at >= '2026-03-01 00:00:00+09' AND shipped_at < '2026-03-08 00:00:00+09';
EXPLAIN (COSTS OFF)
SELECT count(*), sum(weight_g) FROM shipments_random
 WHERE shipped_at >= '2026-03-01 00:00:00+09' AND shipped_at < '2026-03-08 00:00:00+09';
