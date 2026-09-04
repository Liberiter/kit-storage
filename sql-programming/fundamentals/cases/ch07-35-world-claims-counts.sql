-- 7장 본문이 인용하는 world 수치 주장. 각 행이 "주장 → 실측값(개수)" 쌍이다.
-- 출력 블록이 없어 러너 대조에서 빠지는 주장들을 여기서 고정한다 (D-017·D-021).
--  · 들어가며·7.2 문제 상황: order_items 1243행, books 320종, orders 620건,
--    customers 150명, reviews 520건
--  · 7.1 문제 상황·흔한 실수: 이름이 겹치는 고객 그룹 31, 이름 '최연우' 3명
--  · 7.2 왜 그럴까요·흔한 실수: 구매 인증 리뷰 300건, 일반 리뷰 220건,
--    책숲의 외래키 제약 6개
--  · 7.3 따라 하기 2·3·4단계: 조인 결과 1243행, 여행 분야 주문 항목 148건,
--    부산 고객 16명·그 주문 66건
--  · 7.3 practice 2: 요리 분야 주문 항목 187건
--  · 7.3 왜 그럴까요: reviews INNER JOIN orders 300행, reviews INNER JOIN books 520행
--  · exercise 1·2·3, 복습 exercise: 160·81·44·42건
--  · problem 1·2·3: 77·172·220건
--  · 복습 exercise·problem 3의 채점 포인트가 드는 반례 두 건 (제목이 정확히
--    '여행'인 책 0종, `order_id = NULL`로 걸렀을 때 0행)
--  · exercise 3·problem 1·problem 2의 채점 포인트가 드는 동점 근거 (서울·2026년
--    주문에서 날짜가 겹치는 날 2일, problem 1 상위 다섯 줄 중 셋이 같은 날짜,
--    재고 부족 항목이 둘 이상인 주문 9건)
SELECT 'order_items 행 수' AS claim, count(*) AS value FROM order_items
UNION ALL SELECT 'books 행 수', count(*) FROM books
UNION ALL SELECT 'orders 행 수', count(*) FROM orders
UNION ALL SELECT 'customers 행 수', count(*) FROM customers
UNION ALL SELECT 'reviews 행 수', count(*) FROM reviews
UNION ALL SELECT '이름이 겹치는 고객 그룹 수',
       (SELECT count(*) FROM (SELECT name FROM customers
                               GROUP BY name HAVING count(*) > 1) t)
UNION ALL SELECT '이름이 최연우인 고객 수',
       (SELECT count(*) FROM customers WHERE name = '최연우')
UNION ALL SELECT '책숲의 외래키 제약 수',
       (SELECT count(*) FROM pg_constraint
         WHERE contype = 'f' AND connamespace = 'public'::regnamespace)
UNION ALL SELECT '구매 인증 리뷰 수 (order_id 있음)',
       (SELECT count(*) FROM reviews WHERE order_id IS NOT NULL)
UNION ALL SELECT '일반 리뷰 수 (order_id 널)',
       (SELECT count(*) FROM reviews WHERE order_id IS NULL)
UNION ALL SELECT 'order_items INNER JOIN books 행 수',
       (SELECT count(*) FROM order_items i
          JOIN books b ON i.book_id = b.book_id)
UNION ALL SELECT 'reviews INNER JOIN orders 행 수',
       (SELECT count(*) FROM reviews r JOIN orders o ON r.order_id = o.order_id)
UNION ALL SELECT 'reviews INNER JOIN books 행 수',
       (SELECT count(*) FROM reviews r JOIN books b ON r.book_id = b.book_id)
UNION ALL SELECT '여행 분야 주문 항목 수',
       (SELECT count(*) FROM order_items i JOIN books b ON i.book_id = b.book_id
         WHERE b.category = '여행')
UNION ALL SELECT '요리 분야 주문 항목 수',
       (SELECT count(*) FROM order_items i JOIN books b ON i.book_id = b.book_id
         WHERE b.category = '요리')
UNION ALL SELECT '부산 고객 수', (SELECT count(*) FROM customers WHERE city = '부산')
UNION ALL SELECT '부산 고객의 주문 수',
       (SELECT count(*) FROM orders o JOIN customers c
               ON o.customer_id = c.customer_id WHERE c.city = '부산')
UNION ALL SELECT '도서 29번이 담긴 주문 항목 수',
       (SELECT count(*) FROM order_items WHERE book_id = 29)
UNION ALL SELECT 'exercise 1 — 별점 5점 리뷰 수',
       (SELECT count(*) FROM reviews r JOIN books b ON r.book_id = b.book_id
         WHERE r.rating = 5)
UNION ALL SELECT 'exercise 2 — 요리 2권 이상 항목 수',
       (SELECT count(*) FROM order_items i JOIN books b ON i.book_id = b.book_id
         WHERE b.category = '요리' AND i.quantity >= 2)
UNION ALL SELECT 'exercise 3 — 서울 고객의 2026년 주문 수',
       (SELECT count(*) FROM orders o JOIN customers c
               ON o.customer_id = c.customer_id
         WHERE c.city = '서울'
           AND o.order_date BETWEEN '2026-01-01' AND '2026-12-31')
UNION ALL SELECT '복습 exercise — 제목에 여행이 든 책의 4점 이상 리뷰 수',
       (SELECT count(*) FROM reviews r JOIN books b ON r.book_id = b.book_id
         WHERE b.title LIKE '%여행%' AND r.rating >= 4)
UNION ALL SELECT 'problem 1 — 별점 1~2점 리뷰 수',
       (SELECT count(*) FROM reviews WHERE rating BETWEEN 1 AND 2)
UNION ALL SELECT 'problem 2 — 재고보다 많이 주문된 항목 수',
       (SELECT count(*) FROM order_items i JOIN books b ON i.book_id = b.book_id
         WHERE b.stock < i.quantity)
UNION ALL SELECT 'problem 3 — 구매 인증이 없는 리뷰 수',
       (SELECT count(*) FROM reviews r JOIN books b ON r.book_id = b.book_id
         WHERE r.order_id IS NULL)
UNION ALL SELECT '복습 exercise 채점 포인트 — 제목이 정확히 여행인 책 수',
       (SELECT count(*) FROM books WHERE title = '여행')
UNION ALL SELECT 'problem 3 채점 포인트 — order_id = NULL로 걸렀을 때의 행 수',
       (SELECT count(*) FROM reviews WHERE order_id = NULL)
UNION ALL SELECT 'exercise 3 채점 포인트 — 서울·2026년 주문 중 같은 날짜가 겹치는 날 수',
       (SELECT count(*) FROM (SELECT o.order_date FROM orders o
                                JOIN customers c ON o.customer_id = c.customer_id
                               WHERE c.city = '서울'
                                 AND o.order_date BETWEEN '2026-01-01' AND '2026-12-31'
                               GROUP BY o.order_date HAVING count(*) > 1) t)
UNION ALL SELECT 'problem 1 채점 포인트 — 상위 다섯 줄 중 리뷰 30·51·100번의 수',
       (SELECT count(*) FROM (SELECT review_id FROM reviews
                               WHERE rating BETWEEN 1 AND 2
                               ORDER BY review_date DESC, review_id LIMIT 5) t
         WHERE t.review_id IN (30, 51, 100))
UNION ALL SELECT 'problem 1 채점 포인트 — 리뷰 30·51·100번의 review_date 가짓수',
       (SELECT count(DISTINCT review_date) FROM reviews
         WHERE review_id IN (30, 51, 100))
UNION ALL SELECT 'problem 2 채점 포인트 — 재고 부족 항목이 둘 이상인 주문 수',
       (SELECT count(*) FROM (SELECT i.order_id FROM order_items i
                                JOIN books b ON i.book_id = b.book_id
                               WHERE b.stock < i.quantity
                               GROUP BY i.order_id HAVING count(*) > 1) t);
