-- 11장 11.1 «따라 하기» 1단계: EXPLAIN 으로 계획을 묻는다 — Seq Scan 과 Filter, 괄호 안의 네 수
EXPLAIN
SELECT view_id, viewed_at, customer_id FROM page_views WHERE book_id = 12;
