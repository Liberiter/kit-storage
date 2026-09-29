-- 11장 11.1 «따라 하기» 2단계: 기본키 조건은 Index Scan — 그 인덱스는 \d 의 Indexes: 줄에 있다
EXPLAIN
SELECT view_id, viewed_at, book_id FROM page_views WHERE view_id = 12345;

\d page_views
