-- 12장 복습 exercise 3 (11장) 지문: 7번 고객의 조회 기록에서 고객 번호를 지우는 UPDATE의 계획
EXPLAIN (COSTS OFF)
UPDATE page_views SET customer_id = NULL WHERE customer_id = 7;
