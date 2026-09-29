-- runner: reset
-- 11장 «연습하기» exercise 4: customer_id 인덱스가 있어도 IS NULL 은 Seq Scan — 고르는 줄이 전체의 절반을 넘는다
CREATE INDEX page_views_customer_id_idx ON page_views (customer_id);

EXPLAIN (COSTS OFF)
SELECT view_id, book_id FROM page_views WHERE customer_id IS NULL;

SELECT
    count(*) AS 전체조회수,
    count(*) FILTER (WHERE customer_id IS NULL) AS 비로그인조회수
FROM page_views;
