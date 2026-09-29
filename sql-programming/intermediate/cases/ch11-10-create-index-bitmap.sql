-- runner: reset
-- 11장 11.2 «따라 하기» 1단계: book_id 에 인덱스를 만들면 Bitmap Index Scan + Bitmap Heap Scan, 비용 어림이 준다
CREATE INDEX page_views_book_id_idx ON page_views (book_id);

EXPLAIN
SELECT view_id, viewed_at, customer_id FROM page_views WHERE book_id = 12;
