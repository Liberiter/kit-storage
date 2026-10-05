-- measure.sql — measure.sh 가 psql 한 세션에 흘려 넣는 측정 절차. 여러분이 직접 실행하는 파일이 아니다.
-- 「-- @run」 아래 블록을 measure.sh 가 반복 횟수만큼 이어 붙이고, 「-- @tail」 아래를 끝에 한 번 붙인다.
-- 재는 질의는 psql 변수 q 로 들어온다 (measure.sh 가 -v q=<파일 내용> 으로 넘긴다).
SET client_min_messages = warning;

-- 질의 하나를 EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) 으로 실행해 계획을 JSON 으로 돌려준다.
CREATE FUNCTION pg_temp.kit_measure(q text) RETURNS jsonb LANGUAGE plpgsql AS $f$
DECLARE r jsonb;
BEGIN
  EXECUTE 'EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) ' || q INTO r;
  -- 문장이 여럿이면 EXECUTE 는 마지막 문장의 결과를 돌려준다 — 계획이 아니면 거절한다.
  IF jsonb_typeof(r) IS DISTINCT FROM 'array' OR r->0->'Plan' IS NULL THEN
    RAISE EXCEPTION 'measure: 질의 파일에는 문장이 하나만 있어야 합니다 (계획을 받지 못했습니다)';
  END IF;
  RETURN r;
END $f$;

-- 계획 노드 한 줄: 이름(병렬·집계 방식 포함) + 대상 테이블·인덱스 + 디스크를 쓴 정렬·해시 표시.
CREATE FUNCTION pg_temp.kit_node(p jsonb) RETURNS text LANGUAGE sql AS $f$
  SELECT CASE WHEN (p->>'Parallel Aware')::boolean THEN 'Parallel ' ELSE '' END
      || CASE WHEN p->>'Node Type' = 'ModifyTable' THEN p->>'Operation'
              WHEN p->>'Node Type' = 'Aggregate' THEN
                coalesce(CASE p->>'Partial Mode' WHEN 'Partial' THEN 'Partial ' WHEN 'Finalize' THEN 'Finalize ' END, '')
             || CASE p->>'Strategy' WHEN 'Hashed' THEN 'HashAggregate' WHEN 'Sorted' THEN 'GroupAggregate'
                                    WHEN 'Mixed' THEN 'MixedAggregate' ELSE 'Aggregate' END
              ELSE p->>'Node Type' END
      || coalesce(' on ' || (p->>'Relation Name'), '')
      || coalesce(' using ' || (p->>'Index Name'), '')
      || CASE WHEN p->>'Sort Space Type' = 'Disk' THEN ' (디스크 사용: ' || (p->>'Sort Method') || ')' ELSE '' END
      || CASE WHEN (p->>'Hash Batches')::int > 1 THEN ' (해시 배치 ' || (p->>'Hash Batches') || '개 — 디스크 사용)' ELSE '' END
      || CASE WHEN (p->>'HashAgg Batches')::int > 1 THEN ' (해시 배치 ' || (p->>'HashAgg Batches') || '개 — 디스크 사용)' ELSE '' END
$f$;

-- 계획 트리를 EXPLAIN 과 같은 차례·들여쓰기의 줄들로 편다. ord 는 차례를 정하는 열쇠다.
CREATE FUNCTION pg_temp.kit_shape(p jsonb, depth int, pos int) RETURNS TABLE (ord text, line text) LANGUAGE sql AS $f$
  SELECT lpad(pos::text, 4, '0'),
         repeat('  ', depth) || CASE WHEN depth > 0 THEN '-> ' ELSE '' END || pg_temp.kit_node(p)
  UNION ALL
  SELECT lpad(pos::text, 4, '0') || s.ord, s.line
    FROM jsonb_array_elements(coalesce(p->'Plans', '[]'::jsonb)) WITH ORDINALITY AS c(child, i),
         LATERAL pg_temp.kit_shape(c.child, depth + 1, c.i::int) s
$f$;

-- @run
-- 실행 한 번: 트랜잭션 안에서 잰 뒤 되돌리고, 「__RUN__ 실행ms 계획ms hit read 계획지문」 한 줄을 낸다.
BEGIN;
SELECT pg_temp.kit_measure(:'q') AS j \gset m_
ROLLBACK;
SELECT '__RUN__ ' || (j->0->>'Execution Time') || ' ' || (j->0->>'Planning Time') || ' '
       || coalesce(j->0->'Plan'->>'Shared Hit Blocks', '0') || ' '
       || coalesce(j->0->'Plan'->>'Shared Read Blocks', '0') || ' '
       || md5((SELECT string_agg(line, E'\n' ORDER BY ord) FROM pg_temp.kit_shape(j->0->'Plan', 0, 1)))
  FROM (SELECT :'m_j'::jsonb AS j) t;

-- @tail
-- 마지막 실행의 계획 모양.
SELECT '__SHAPE__ ' || line FROM pg_temp.kit_shape(:'m_j'::jsonb->0->'Plan', 0, 1) ORDER BY ord;
