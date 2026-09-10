-- runner: reset
-- smoke: 실행 계획 — 인덱스를 만들기 전후로 스캔 유형이 갈리는지 (11장 요구 예시)
-- COSTS OFF 로 비용·추정 행 수를 빼고 계획의 모양만 고정한다.
EXPLAIN (COSTS OFF)
SELECT count(*) FROM page_views WHERE book_id = 12;

CREATE INDEX page_views_book_id_idx ON page_views (book_id);

EXPLAIN (COSTS OFF)
SELECT count(*) FROM page_views WHERE book_id = 12;

SELECT count(*) FROM page_views WHERE book_id = 12;
