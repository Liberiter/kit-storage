-- runner: reset
-- 12장 복습 exercise 3 (11장) 해설: customer_id에 인덱스를 만든 뒤 같은 UPDATE의 계획과 고칠 행 수
CREATE INDEX page_views_customer_id_idx ON page_views (customer_id);

EXPLAIN (COSTS OFF)
UPDATE page_views SET customer_id = NULL WHERE customer_id = 7;

SELECT count(*) AS 고칠줄수 FROM page_views WHERE customer_id = 7;
