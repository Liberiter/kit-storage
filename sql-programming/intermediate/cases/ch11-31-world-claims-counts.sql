-- 11장 주장 케이스 (정수) — 본문에 블록으로 등장하지 않는 world 의 수치·사실
--   books 행 수 → 11.1 «왜 그럴까요» 「320권을 통째로」, 연습하기 exercise 1 채점 포인트 「320권뿐인 작은 테이블」
--   books 의 기본키 인덱스 books_pkey → 11.1 «왜 그럴까요» 「books_pkey 인덱스가 있습니다」
--   customers 행 수 → 복습 exercise 1 채점 포인트 「150명뿐」
--   처음 상태 page_views 의 인덱스 수 → 11.1 «따라 하기» 2단계 「page_views 의 인덱스는 이것 하나뿐」 (\d 출력에도 보인다)
--   서울 기준 6월 1일 ~ 8월 31일 밖의 조회 → 연습하기 exercise 3 「석 달 동안」·「조회 로그는 여름 석 달치」
--   12번 책의 줄이 걸친 페이지 수와 표 전체 페이지 수 → 11.2 «따라 하기» 1단계 「테이블 곳곳에 흩어져」
--   서울 8월 15일 하루치 줄이 걸친 페이지 수와 그 페이지 번호의 폭 → 11.2 practice 2 「같은 날의 행이 테이블 안에 모여」
SELECT 'books 행 수' AS 주장, count(*) AS 실측값 FROM books
UNION ALL
SELECT 'books 의 books_pkey 인덱스', count(*)
FROM pg_indexes WHERE tablename = 'books' AND indexname = 'books_pkey'
UNION ALL
SELECT 'customers 행 수', count(*) FROM customers
UNION ALL
SELECT '처음 상태 page_views 의 인덱스 수', count(*)
FROM pg_indexes WHERE tablename = 'page_views'
UNION ALL
SELECT '서울 기준 6월 1일 ~ 8월 31일 밖의 조회', count(*)
FROM page_views
WHERE viewed_at < '2026-06-01 00:00:00+09' OR viewed_at >= '2026-09-01 00:00:00+09'
UNION ALL
SELECT '12번 책의 줄이 걸친 페이지 수', count(DISTINCT (ctid::text::point)[0])::bigint
FROM page_views WHERE book_id = 12
UNION ALL
SELECT 'page_views 전체 페이지 수', count(DISTINCT (ctid::text::point)[0])::bigint
FROM page_views
UNION ALL
SELECT '서울 8월 15일 하루치 줄이 걸친 페이지 수', count(DISTINCT (ctid::text::point)[0])::bigint
FROM page_views
WHERE viewed_at >= '2026-08-15 00:00:00+09' AND viewed_at < '2026-08-16 00:00:00+09'
UNION ALL
SELECT '서울 8월 15일 하루치 페이지 번호의 폭',
    (max((ctid::text::point)[0]) - min((ctid::text::point)[0]) + 1)::bigint
FROM page_views
WHERE viewed_at >= '2026-08-15 00:00:00+09' AND viewed_at < '2026-08-16 00:00:00+09';
