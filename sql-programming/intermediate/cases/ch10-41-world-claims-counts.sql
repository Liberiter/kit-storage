-- 10장 주장 케이스 (정수) — 본문에 코드 블록으로 등장하지 않는다.
-- 출력 블록에서 여러분이 셀 수 없는 수치 주장을 한 표에 모아 고정한다 (D-017·D-021).
-- UNION ALL 의 줄 차례는 보장되지 않으므로 주장 이름 차례로 늘어놓는다.
-- 뒷받침하는 자리:
--   orders 의 행 620 → 10.2 «흔한 실수»의 「세 고객 모두 620 — 책숲의 주문 전체입니다」
--   orders.customer_id 가 널인 행 0 → 10.2 «흔한 실수»의 「널이 아닌 열을 자기 자신과 견주었으니」
--   reviews 의 행 520 → «연습하기» exercise 3 힌트의 「520은 reviews 의 행 전체 수」
--   여행 분야 책 36 → 10.3 «따라 하기» 2단계의 「여행 분야 책이 서른여섯 권이라」
--   3번 책의 판매가 22500 → 10.3 «따라 하기» 3단계의 「3번 책의 판매가가 22500원이라」
--   리뷰가 하나도 없는 책 76 → «연습하기» exercise 1 채점 포인트의 「리뷰가 하나도 없는 책 76권」
--   원장의 조정 줄 0, 원장 합계와 재고가 어긋난 책 0 → «연습하기» exercise 4 지문의 「책마다 quantity 의
--     합이 books.stock 과 같습니다」와 채점 포인트의 「world의 원장에 원래 조정 기록이 없었기 때문」
--   책이 달리지 않는 분류 4 → «복습 exercise» 1 채점 포인트의 「책이 달리지 않는 분류는 짝이 없어 사라지는데」
--   36번 책에 대한 48번 고객의 리뷰 번호 1, 48번 고객이 1번 책에 쓴 리뷰 0
--     → «도전하기» problem 1 지문과 채점 포인트의 「1번 리뷰」·「48번 고객의 1번 책 리뷰는 부딪힐 행이 없어」
--   한 줄 평이 널인 리뷰 189 → «도전하기» problem 1 채점 포인트의 「별점만 남긴 리뷰는 한 줄 평이 널이라」
--   고객 150 → «도전하기» problem 2 채점 포인트의 「150명 모두가 뷰에 있고」
SELECT '36번 책 48번 고객의 리뷰 번호' AS 주장, min(review_id) AS 실측값
FROM reviews
WHERE book_id = 36 AND customer_id = 48
UNION ALL
SELECT '3번 책의 판매가', price FROM books WHERE book_id = 3
UNION ALL
SELECT '48번 고객이 1번 책에 쓴 리뷰 수', count(*)
FROM reviews
WHERE book_id = 1 AND customer_id = 48
UNION ALL
SELECT 'customers 의 행 수', count(*) FROM customers
UNION ALL
SELECT 'orders 의 행 수', count(*) FROM orders
UNION ALL
SELECT 'orders.customer_id 가 널인 행', count(*)
FROM orders
WHERE customer_id IS NULL
UNION ALL
SELECT 'reviews 의 행 수', count(*) FROM reviews
UNION ALL
SELECT '리뷰가 없는 책', count(*)
FROM books
WHERE NOT EXISTS (SELECT 1 FROM reviews WHERE reviews.book_id = books.book_id)
UNION ALL
SELECT '원장 합계와 재고가 어긋난 책', count(*)
FROM books
WHERE stock <> (
    SELECT sum(quantity)
    FROM stock_movements
    WHERE stock_movements.book_id = books.book_id
)
UNION ALL
SELECT '원장의 조정 줄', count(*) FROM stock_movements WHERE reason = '조정'
UNION ALL
SELECT '여행 분야 책 수', count(*) FROM books WHERE category = '여행'
UNION ALL
SELECT '책이 달리지 않는 분류 수', count(*)
FROM categories
WHERE NOT EXISTS (SELECT 1 FROM books WHERE books.category = categories.name)
UNION ALL
SELECT '한 줄 평이 널인 리뷰 수', count(*) FROM reviews WHERE comment IS NULL
ORDER BY 주장;
