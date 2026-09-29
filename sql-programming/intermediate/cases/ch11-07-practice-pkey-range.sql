-- 11장 11.1 «practice» 1: 기본키 범위 조건 — Index Scan, BETWEEN 이 Index Cond 에서 두 비교로 풀린다
EXPLAIN (COSTS OFF)
SELECT view_id, viewed_at, book_id
FROM page_views
WHERE view_id BETWEEN 1000 AND 1010;
