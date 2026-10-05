-- 시나리오: 대량 UPDATE 와 블로트 — 모든 행을 고치면 테이블이 커지고, VACUUM 은 공간을 재사용할 수 있게
-- 할 뿐 파일을 줄이지 않으며, VACUUM FULL 이 테이블을 다시 써서 줄인다. (세션 하나만 쓴다.)
-- 실행: ./sessions.sh scenarios/bloat-update.sql
-- 재료: shipments_sorted (54만 행). 자동 뒷정리가 도중에 끼어들지 않게 그 테이블만 꺼 둔다.

-- @A
-- 처음 크기와 죽은 행 버전 수.
ALTER TABLE shipments_sorted SET (autovacuum_enabled = off);
SELECT pg_size_pretty(pg_relation_size('shipments_sorted')) AS heap_size,
       (pgstattuple('shipments_sorted')).dead_tuple_count;

-- @A
-- 모든 행의 무게를 1g 씩 고칩니다. 행마다 새 버전이 생기고 옛 버전이 남습니다.
UPDATE shipments_sorted SET weight_g = weight_g + 1;
SELECT pg_size_pretty(pg_relation_size('shipments_sorted')) AS heap_size,
       (pgstattuple('shipments_sorted')).dead_tuple_count;

-- @A
-- VACUUM: 옛 버전을 지워 그 자리를 다시 쓸 수 있게 합니다. 파일 크기는 그대로입니다.
VACUUM shipments_sorted;
SELECT pg_size_pretty(pg_relation_size('shipments_sorted')) AS heap_size,
       (pgstattuple('shipments_sorted')).dead_tuple_count,
       round((pgstattuple('shipments_sorted')).free_percent) AS free_pct;

-- @A
-- VACUUM FULL: 테이블을 새로 써서 빈 자리를 없앱니다. 그동안 테이블 전체를 잠급니다.
VACUUM FULL shipments_sorted;
SELECT pg_size_pretty(pg_relation_size('shipments_sorted')) AS heap_size,
       (pgstattuple('shipments_sorted')).dead_tuple_count;

-- @expect A ok
