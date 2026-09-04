-- 10장 본문이 인용하는 world 수치 주장. 각 행이 "주장 → 실측값(개수)" 쌍이다.
-- 출력 블록이 없거나 LIMIT으로 잘려 학습자가 셀 수 없는 주장을 여기서 고정한다
-- (D-017·D-021·D-033).
--  · 들어가며·10.1 문제 상황: books 320권, reviews 520건, orders 620건,
--    customers 150명, 분야는 여덟 가지
--  · 10.1 따라 하기 1단계·개념: 평균 가격을 넘는 책 156권 (본문은 다섯 권만 싣는다)
--  · 10.1 따라 하기 3단계: 과학 분야 29권
--  · 10.1 따라 하기 5단계: 리뷰가 하나도 없는 책 76권, reviews.book_id가 널인 행 0행
--  · 10.1 왜 그럴까요: '만화' 분야 책 0권
--  · 10.1 흔한 실수: reviews.order_id가 널인 행 220행, 구매 인증 리뷰가 붙지 않은
--    주문 391건
--  · 10.1 practice 1: 평균 쪽수를 넘는 책 160권
--  · 10.2 문제 상황·따라 하기: 주문 20건 이상인 손님 7명, 리뷰 10건 이상인 손님 7명
--  · exercise 2: 취소한 주문이 있는 손님 35명
--  · exercise 3: 과학 분야 최고가 41,000원
--  · exercise 4: 한 번도 주문되지 않은 책 18권
--  · exercise 5: 제목에 '여행'이 들고 평균 가격을 넘는 책 17권
--  · exercise 6: 주문이 하나도 없는 손님 29명
--  · problem 2: 리뷰는 썼지만 주문이 없는 손님 24명
--  · problem 3: 재고가 평균보다 적으면서 리뷰가 달린 책 158권
SELECT 'books 행 수' AS claim, count(*) AS value FROM books
UNION ALL SELECT 'customers 행 수', count(*) FROM customers
UNION ALL SELECT 'orders 행 수', count(*) FROM orders
UNION ALL SELECT 'reviews 행 수', count(*) FROM reviews
UNION ALL SELECT 'books.category의 가짓수',
       (SELECT count(*) FROM (SELECT category FROM books
                               GROUP BY category) t)
UNION ALL SELECT '과학 분야 책 수',
       (SELECT count(*) FROM books WHERE category = '과학')
UNION ALL SELECT '과학 분야 최고가',
       (SELECT max(price) FROM books WHERE category = '과학')
UNION ALL SELECT '만화 분야 책 수',
       (SELECT count(*) FROM books WHERE category = '만화')
UNION ALL SELECT '평균 가격을 넘는 책 수',
       (SELECT count(*) FROM books
         WHERE price > (SELECT avg(price) FROM books))
UNION ALL SELECT '평균 쪽수를 넘는 책 수',
       (SELECT count(*) FROM books
         WHERE page_count > (SELECT avg(page_count) FROM books))
UNION ALL SELECT '리뷰가 하나도 없는 책 수',
       (SELECT count(*) FROM books
         WHERE book_id NOT IN (SELECT book_id FROM reviews))
UNION ALL SELECT 'reviews.book_id가 널인 행 수 (널을 허용하지 않는 열이다)',
       (SELECT count(*) FROM reviews WHERE book_id IS NULL)
UNION ALL SELECT 'reviews.order_id가 널인 행 수',
       (SELECT count(*) FROM reviews WHERE order_id IS NULL)
UNION ALL SELECT '구매 인증 리뷰가 붙지 않은 주문 수',
       (SELECT count(*) FROM orders
         WHERE order_id NOT IN (SELECT order_id FROM reviews
                                 WHERE order_id IS NOT NULL))
UNION ALL SELECT '주문이 20건 이상인 손님 수',
       (SELECT count(*) FROM (SELECT customer_id FROM orders
                               GROUP BY customer_id
                              HAVING count(*) >= 20) t)
UNION ALL SELECT '리뷰가 10건 이상인 손님 수',
       (SELECT count(*) FROM (SELECT customer_id FROM reviews
                               GROUP BY customer_id
                              HAVING count(*) >= 10) t)
UNION ALL SELECT '취소한 주문이 있는 손님 수',
       (SELECT count(*) FROM customers
         WHERE customer_id IN (SELECT customer_id FROM orders
                                WHERE status = '취소'))
UNION ALL SELECT '한 번도 주문되지 않은 책 수',
       (SELECT count(*) FROM (SELECT book_id FROM books
                               EXCEPT
                              SELECT book_id FROM order_items) t)
UNION ALL SELECT '제목에 ''여행''이 들고 평균 가격을 넘는 책 수',
       (SELECT count(*) FROM books
         WHERE title LIKE '%여행%'
           AND price > (SELECT avg(price) FROM books))
UNION ALL SELECT '주문이 하나도 없는 손님 수',
       (SELECT count(*) FROM (SELECT customer_id FROM customers
                               EXCEPT
                              SELECT customer_id FROM orders) t)
UNION ALL SELECT '리뷰는 썼지만 주문이 없는 손님 수',
       (SELECT count(*) FROM (SELECT customer_id FROM reviews
                               EXCEPT
                              SELECT customer_id FROM orders) t)
UNION ALL SELECT '재고가 평균보다 적으면서 리뷰가 달린 책 수',
       (SELECT count(*) FROM books
         WHERE stock < (SELECT avg(stock) FROM books)
           AND book_id IN (SELECT book_id FROM reviews));
