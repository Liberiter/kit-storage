-- 1장이 산문으로 인용하는 world 의 정수 수치. 본문에 코드 블록으로 등장하지 않아
-- 러너의 출력 대조에서 빠지므로, 각 행을 「주장 → 실측값」 쌍으로 고정한다.
-- 뒷받침하는 본문 자리는 절 이름으로 적는다 — 행 번호는 본문이 바뀌면 낡는다.
--   status 가짓수 4     → 1.2 «practice» 1 「주문 상태 네 가지」,
--                         1.3 «따라 하기» 2단계 「상태 넷이 서로 겹치지 않고 빠짐도 없다」
--   분야 가짓수 8       → 1.2 «문제 상황» 「분야가 여덟이니 … 서른둘이 됩니다」
--   책값 최고가 42000   → 1.3 «흔한 실수» 「가장 비싼 책이 42,000원」
--   45000 이상 0권      → 1.3 «흔한 실수» 「45,000원 이상인 책은 한 권도 없습니다」
--   리뷰 5건인 책 12권  → «연습하기» exercise 1 «채점 포인트» 「5건짜리가 열두 권」.
--                         그 출력은 LIMIT 5 로 잘려 학습자가 셀 수 없는 자리다
--   책 권수 320         → «복습 exercise» 3 «채점 포인트» 「다 더하면 320」
--   상반기 매출 14834000 → 1.1 «따라 하기» 6단계, 1.1 «practice» 1 «해설»
-- 나머지 네 행(주문 620·주문 항목 1243·리뷰 520·2026 상반기 주문 214)은 본문이
-- 인용하지 않는다. world 규모가 바뀌면 이 장의 출력 케이스가 통째로 흔들리므로
-- 회귀 검증용 고정값으로 남겨 둔다.
SELECT 'orders.status 에 실제로 쓰인 값의 가짓수' AS claim,
       (SELECT count(DISTINCT status) FROM orders) AS value
UNION ALL
SELECT 'books.category 에 실제로 쓰인 값의 가짓수',
       (SELECT count(DISTINCT category) FROM books)
UNION ALL
SELECT '책값의 최고가',
       (SELECT max(price) FROM books)
UNION ALL
SELECT '값이 45000 이상인 책 권수',
       (SELECT count(*) FROM books WHERE price >= 45000)
UNION ALL
SELECT '리뷰가 정확히 5건 달린 책 권수',
       (SELECT count(*) FROM (SELECT book_id FROM reviews
                               GROUP BY book_id HAVING count(*) = 5) t)
UNION ALL
SELECT '책숲의 책 권수',
       (SELECT count(*) FROM books)
UNION ALL
SELECT '2026-01-01~2026-06-30 취소 제외 주문의 매출 합계',
       (SELECT sum(order_items.unit_price * order_items.quantity)
          FROM orders
          INNER JOIN order_items ON orders.order_id = order_items.order_id
         WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
           AND orders.status <> '취소')
UNION ALL
SELECT '책숲의 주문 건수 (본문 미인용 — 회귀 검증용)',
       (SELECT count(*) FROM orders)
UNION ALL
SELECT '책숲의 주문 항목 줄 수 (본문 미인용 — 회귀 검증용)',
       (SELECT count(*) FROM order_items)
UNION ALL
SELECT '책숲의 리뷰 건수 (본문 미인용 — 회귀 검증용)',
       (SELECT count(*) FROM reviews)
UNION ALL
SELECT '2026-01-01~2026-06-30 에 들어온 주문 건수, 취소 포함 (본문 미인용 — 회귀 검증용)',
       (SELECT count(*) FROM orders
         WHERE order_date BETWEEN '2026-01-01' AND '2026-06-30');
