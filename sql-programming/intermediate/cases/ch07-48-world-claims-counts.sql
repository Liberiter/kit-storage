-- 7장 주장 케이스 — 본문에 코드 블록으로 등장하지 않는다.
-- 출력 블록에서 학습자가 셀 수 없는 수치 주장을 한 표에 모아 고정한다 (D-017·D-021).
-- 뒷받침하는 자리:
--   피드 줄 수 85 / 서로 다른 책 번호 60 / books 에 있는 책 59 → 7.1 «개념»,
--     7.2 «따라 하기» 5단계 해설
--   2026-08-25 피드 줄 수 39·서로 다른 책 38 → 7.2 «따라 하기» 2단계 해설
--   2026-09-01 피드 줄 수 46 → 7.2 «practice» 1 해설
--   supplier_feed 의 CHECK 와 UNIQUE 제약 0개 → 7.1 «문제 상황»
--   reviews 의 rating·review_date 가 널 금지 열(둘) → 7.3 «개념» 판별 조건,
--     «도전하기» problem 2 «채점 포인트»
--   book_supply 의 CHECK 제약 2개 → 7.1 «문제 상황»
--   book_meta 의 UNIQUE 제약 1개 → 7.1 «흔한 실수»
--   (book_id, customer_id) 가 겹치는 리뷰 0행 → «도전하기» problem 2 지문
--   이미 공급 현황에 있는 책 39·없는 책 20 → 7.3 «따라 하기» 5단계 해설
--   공급가가 양수인데 같은 책이 두 줄인 자리: 08-25 는 1, 09-01 은 0 → «연습하기»
--     exercise 3 «채점 포인트»의 「둘째 피드에서는 음수 조건이 겹침을 이미 걸러
--     내지만 첫 피드에서는 두 줄이 둘 다 멀쩡한 값이라 걸러지지 않는다」
SELECT '피드 줄 수' AS 주장, count(*) AS 실측값 FROM supplier_feed
UNION ALL
SELECT '피드에 이름이 오른 서로 다른 책 번호 수', count(DISTINCT book_id)
FROM supplier_feed
UNION ALL
SELECT '그 가운데 books 에 있는 책 수', count(DISTINCT f.book_id)
FROM supplier_feed AS f
INNER JOIN books AS b ON b.book_id = f.book_id
UNION ALL
SELECT '2026-08-25 피드 줄 수', count(*)
FROM supplier_feed WHERE feed_date = '2026-08-25'
UNION ALL
SELECT '2026-08-25 피드의 서로 다른 책 수', count(DISTINCT book_id)
FROM supplier_feed WHERE feed_date = '2026-08-25'
UNION ALL
SELECT '2026-09-01 피드 줄 수', count(*)
FROM supplier_feed WHERE feed_date = '2026-09-01'
UNION ALL
SELECT 'supplier_feed 의 CHECK 와 UNIQUE 제약 수', count(*)
FROM pg_constraint
WHERE conrelid = 'supplier_feed'::regclass AND contype IN ('c', 'u')
UNION ALL
SELECT 'book_supply 의 CHECK 제약 수', count(*)
FROM pg_constraint
WHERE conrelid = 'book_supply'::regclass AND contype = 'c'
UNION ALL
SELECT 'book_meta 의 UNIQUE 제약 수', count(*)
FROM pg_constraint
WHERE conrelid = 'book_meta'::regclass AND contype = 'u'
UNION ALL
SELECT '도서와 고객 조합이 겹치는 리뷰 행 수', count(*)
FROM (
    SELECT book_id, customer_id FROM reviews
    GROUP BY book_id, customer_id HAVING count(*) > 1
) AS dup
UNION ALL
SELECT '피드의 책 가운데 공급 현황에 이미 있는 책 수', count(*)
FROM (SELECT DISTINCT f.book_id FROM supplier_feed AS f
      INNER JOIN books AS b ON b.book_id = f.book_id) AS fed
INNER JOIN book_supply AS s ON s.book_id = fed.book_id
UNION ALL
SELECT '피드의 책 가운데 공급 현황에 없는 책 수', count(*)
FROM (SELECT DISTINCT f.book_id FROM supplier_feed AS f
      INNER JOIN books AS b ON b.book_id = f.book_id) AS fed
LEFT JOIN book_supply AS s ON s.book_id = fed.book_id
WHERE s.book_id IS NULL
UNION ALL
SELECT '08-25 피드에서 공급가가 양수인데 같은 책이 두 줄인 자리 수', count(*)
FROM (
    SELECT book_id FROM supplier_feed
    WHERE feed_date = '2026-08-25' AND supplier_price > 0
    GROUP BY book_id HAVING count(*) > 1
) AS dup1
UNION ALL
SELECT '09-01 피드에서 공급가가 양수인데 같은 책이 두 줄인 자리 수', count(*)
FROM (
    SELECT book_id FROM supplier_feed
    WHERE feed_date = '2026-09-01' AND supplier_price > 0
    GROUP BY book_id HAVING count(*) > 1
) AS dup2
UNION ALL
SELECT 'reviews의 rating·review_date 가운데 널 금지 열의 수', count(*)
FROM pg_attribute
WHERE attrelid = 'reviews'::regclass
  AND attname IN ('rating', 'review_date')
  AND attnotnull;
