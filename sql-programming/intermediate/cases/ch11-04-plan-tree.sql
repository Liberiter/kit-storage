-- 11장 11.1 «따라 하기» 3단계: 문제 상황의 질의를 COSTS OFF 로 — 노드가 여럿인 계획을 아래에서 위로 읽는다
EXPLAIN (COSTS OFF)
SELECT view_id, viewed_at, customer_id
FROM page_views
WHERE book_id = 12
ORDER BY viewed_at DESC
LIMIT 5;
