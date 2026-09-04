-- 5장 본문이 인용하는 world 수치 주장. 각 행이 "주장 → 실측값" 쌍이다.
-- (날짜 주장 세 건은 값의 타입이 달라 ch05-38-world-claims-text로 나눴다.)
--  · 5.1 문제 상황: orders 620행, `= NULL`이 찾은 행 0
--  · 5.1 개념·따라 하기: 발송일 NULL 144·NOT NULL 476, 상태별 개수
--  · 5.1 따라 하기 3·4단계: 생일 NULL 41·NOT NULL 109, 코멘트 NULL 189·NOT NULL 331
--  · 5.1 따라 하기 5단계·problem 1: 발송일 NULL & 취소 아님 83
--  · 5.1 왜 그럴까요: `<> NULL`이 찾은 행 0, 고객 4의 주문 6(발송 2·미발송 4)
--  · 5.1 흔한 실수: `comment = ''`가 찾은 행 0, 취소 주문 61
--  · 5.1 practice 2: 코멘트 없고 별점 5점인 리뷰 64
--  · 5.2 문제 상황·따라 하기: reviews 520행, 별점 5점 리뷰 160
--  · 5.2 practice 2·흔한 실수: order_id NULL 220·NOT NULL 300, 0번 주문은 없다
--  · 5.2 practice 1: 별점 1점 리뷰 23
--  · exercise 3: 2026년 & 별점 3점 이하 리뷰 122
--  · exercise 4: `comment IS NULL`(189) + `comment IS NOT NULL`(331) = 520
--  · problem 2: 별점 4점 이상 리뷰 331
--  · 들어가며·5.1 왜 그럴까요: books 320행·8열 전부 NOT NULL, 여행 36·비여행 284
--    (2·3장이 이미 고정한 주장이지만 5장 본문이 다시 인용하므로 함께 담는다)
SELECT 'orders 전체 행 수' AS claim, (SELECT count(*) FROM orders) AS value
UNION ALL
SELECT 'shipped_date가 NULL인 주문 수',
       (SELECT count(*) FROM orders WHERE shipped_date IS NULL)
UNION ALL
SELECT 'shipped_date가 NULL이 아닌 주문 수',
       (SELECT count(*) FROM orders WHERE shipped_date IS NOT NULL)
UNION ALL
SELECT 'shipped_date = NULL 조건이 찾은 행 수',
       (SELECT count(*) FROM orders WHERE shipped_date = NULL)
UNION ALL
SELECT 'shipped_date <> NULL 조건이 찾은 행 수',
       (SELECT count(*) FROM orders WHERE shipped_date <> NULL)
UNION ALL
SELECT '상태가 배송준비인 주문 수',
       (SELECT count(*) FROM orders WHERE status = '배송준비')
UNION ALL
SELECT '상태가 배송중인 주문 수',
       (SELECT count(*) FROM orders WHERE status = '배송중')
UNION ALL
SELECT '상태가 배송완료인 주문 수',
       (SELECT count(*) FROM orders WHERE status = '배송완료')
UNION ALL
SELECT '상태가 취소인 주문 수',
       (SELECT count(*) FROM orders WHERE status = '취소')
UNION ALL
SELECT '발송일이 없고 취소도 아닌 주문 수',
       (SELECT count(*) FROM orders
         WHERE shipped_date IS NULL AND status <> '취소')
UNION ALL
SELECT '고객 4의 주문 수', (SELECT count(*) FROM orders WHERE customer_id = 4)
UNION ALL
SELECT '고객 4의 주문 중 발송일이 있는 것',
       (SELECT count(*) FROM orders
         WHERE customer_id = 4 AND shipped_date IS NOT NULL)
UNION ALL
SELECT '고객 4의 주문 중 발송일이 없는 것',
       (SELECT count(*) FROM orders
         WHERE customer_id = 4 AND shipped_date IS NULL)
UNION ALL
SELECT '가장 작은 order_id', (SELECT min(order_id) FROM orders)
UNION ALL
SELECT 'customers 전체 행 수', (SELECT count(*) FROM customers)
UNION ALL
SELECT 'birth_date가 NULL인 고객 수',
       (SELECT count(*) FROM customers WHERE birth_date IS NULL)
UNION ALL
SELECT 'birth_date가 NULL이 아닌 고객 수',
       (SELECT count(*) FROM customers WHERE birth_date IS NOT NULL)
UNION ALL
SELECT 'reviews 전체 행 수', (SELECT count(*) FROM reviews)
UNION ALL
SELECT 'comment가 NULL인 리뷰 수',
       (SELECT count(*) FROM reviews WHERE comment IS NULL)
UNION ALL
SELECT 'comment가 NULL이 아닌 리뷰 수',
       (SELECT count(*) FROM reviews WHERE comment IS NOT NULL)
UNION ALL
SELECT 'comment = 빈 문자열 조건이 찾은 행 수',
       (SELECT count(*) FROM reviews WHERE comment = '')
UNION ALL
SELECT 'comment = NULL 조건이 찾은 행 수',
       (SELECT count(*) FROM reviews WHERE comment = NULL)
UNION ALL
SELECT 'order_id가 NULL인 리뷰 수',
       (SELECT count(*) FROM reviews WHERE order_id IS NULL)
UNION ALL
SELECT 'order_id가 NULL이 아닌 리뷰 수',
       (SELECT count(*) FROM reviews WHERE order_id IS NOT NULL)
UNION ALL
SELECT 'order_id가 0인 리뷰 수',
       (SELECT count(*) FROM reviews WHERE order_id = 0)
UNION ALL
SELECT '코멘트가 없고 별점이 5점인 리뷰 수',
       (SELECT count(*) FROM reviews WHERE comment IS NULL AND rating = 5)
UNION ALL
SELECT '별점이 5점인 리뷰 수', (SELECT count(*) FROM reviews WHERE rating = 5)
UNION ALL
SELECT '별점이 1점인 리뷰 수',
       (SELECT count(*) FROM reviews WHERE rating = 1)
UNION ALL
SELECT '별점이 4점 이상인 리뷰 수',
       (SELECT count(*) FROM reviews WHERE rating >= 4)
UNION ALL
SELECT '2026년 리뷰 중 별점 3점 이하인 것',
       (SELECT count(*) FROM reviews
         WHERE rating <= 3 AND review_date >= '2026-01-01')
UNION ALL
SELECT 'books 전체 행 수', (SELECT count(*) FROM books)
UNION ALL
SELECT 'books의 열 수',
       (SELECT count(*) FROM information_schema.columns
         WHERE table_schema = 'public' AND table_name = 'books')
UNION ALL
SELECT 'books의 NOT NULL 열 수',
       (SELECT count(*) FROM information_schema.columns
         WHERE table_schema = 'public' AND table_name = 'books'
           AND is_nullable = 'NO')
UNION ALL
SELECT '여행 분야 도서 수',
       (SELECT count(*) FROM books WHERE category = '여행')
UNION ALL
SELECT '여행 분야가 아닌 도서 수',
       (SELECT count(*) FROM books WHERE category <> '여행');
