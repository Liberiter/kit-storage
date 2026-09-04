-- 8장 본문이 인용하는 world 수치 주장. 각 행이 "주장 → 실측값(개수)" 쌍이다.
-- 출력 블록이 없어 러너 대조에서 빠지는 주장들을 여기서 고정한다 (D-017·D-021).
--  · 들어가며·8.1 문제 상황: customers 150명, orders 620건, 주문 없는 고객 29명,
--    고객 7번의 주문 0건
--  · 8.1 개념·따라 하기 1·3단계: 내부 조인 620행 / 왼쪽 외부 조인 649행,
--    주문 없는 고객 29명
--  · 8.1 따라 하기 4단계: 부산 고객 중 주문 없는 사람 3명
--  · 8.1 왜 그럴까요: orders를 왼쪽에 둔 외부 조인 620행, status가 널인 행 29행
--  · 8.1 흔한 실수: shipped_date가 널인 조인 결과 173행, 취소 조건을 WHERE에
--    걸었을 때와 ON에 걸었을 때의 행 수
--  · 8.1 practice 1·2: 리뷰 없는 책 76권, 서울 고객 중 주문 없는 사람 4명
--  · 8.2 문제 상황·따라 하기: 주문 5번의 항목 2줄, 세 테이블 조인 1243행,
--    네 테이블 조인 1243행, 부산 손님이 산 책 134행, 별점 5점 리뷰 160건
--  · 8.2 따라 하기 4단계·왜 그럴까요: 전부 LEFT로 이은 네 테이블 1272행,
--    잘못 이은 조인의 행 수 1243
--  · 8.2 practice 2: 대구 손님이 산 책 125행
--  · exercise 1~4, 복습 exercise: 18·77·119·6·520건
--  · problem 1·2·3: 29·138건, 취소 주문 61건
--  · 채점 포인트가 드는 근거 (주문 없는 고객 중 가입일이 겹치는 날 0,
--    별점 5점 리뷰가 160건이라 6~10번째도 모두 5점, 한 주문에 같은 분야 책이
--    둘 이상 담긴 경우가 과학 5건·어린이 9건)
--  · 스키마에 대한 주장: orders.status에는 널이 없다(8.1 왜 그럴까요),
--    reviews.comment는 널을 허용한다(exercise 4 채점 포인트),
--    customers와 books를 직접 잇는 외래키는 없다(8.2 개념)
--  · 8.2 문제 상황: 주문 5번을 낸 사람이 부산에 사는 오채원 고객이다
SELECT 'customers 행 수' AS claim, count(*) AS value FROM customers
UNION ALL SELECT 'orders 행 수', count(*) FROM orders
UNION ALL SELECT 'books 행 수', count(*) FROM books
UNION ALL SELECT 'order_items 행 수', count(*) FROM order_items
UNION ALL SELECT 'reviews 행 수', count(*) FROM reviews
UNION ALL SELECT '주문이 하나도 없는 고객 수',
       (SELECT count(*) FROM customers c
          LEFT JOIN orders o ON c.customer_id = o.customer_id
         WHERE o.order_id IS NULL)
UNION ALL SELECT '고객 7번의 주문 수',
       (SELECT count(*) FROM orders WHERE customer_id = 7)
UNION ALL SELECT 'customers INNER JOIN orders 행 수',
       (SELECT count(*) FROM customers c
          JOIN orders o ON c.customer_id = o.customer_id)
UNION ALL SELECT 'customers LEFT JOIN orders 행 수',
       (SELECT count(*) FROM customers c
          LEFT JOIN orders o ON c.customer_id = o.customer_id)
UNION ALL SELECT 'orders LEFT JOIN customers 행 수',
       (SELECT count(*) FROM orders o
          LEFT JOIN customers c ON o.customer_id = c.customer_id)
UNION ALL SELECT 'orders.status가 널인 조인 행 수',
       (SELECT count(*) FROM customers c
          LEFT JOIN orders o ON c.customer_id = o.customer_id
         WHERE o.status IS NULL)
UNION ALL SELECT 'orders.shipped_date가 널인 조인 행 수',
       (SELECT count(*) FROM customers c
          LEFT JOIN orders o ON c.customer_id = o.customer_id
         WHERE o.shipped_date IS NULL)
UNION ALL SELECT '부산 고객 중 주문이 없는 사람 수',
       (SELECT count(*) FROM customers c
          LEFT JOIN orders o ON c.customer_id = o.customer_id
         WHERE c.city = '부산' AND o.order_id IS NULL)
UNION ALL SELECT '서울 고객 중 주문이 없는 사람 수',
       (SELECT count(*) FROM customers c
          LEFT JOIN orders o ON c.customer_id = o.customer_id
         WHERE c.city = '서울' AND o.order_id IS NULL)
UNION ALL SELECT '리뷰가 하나도 없는 책 수',
       (SELECT count(*) FROM books b
          LEFT JOIN reviews r ON b.book_id = r.book_id
         WHERE r.review_id IS NULL)
UNION ALL SELECT '주문 5번의 항목 수',
       (SELECT count(*) FROM order_items WHERE order_id = 5)
UNION ALL SELECT 'orders-order_items-books 세 테이블 조인 행 수',
       (SELECT count(*) FROM orders o
          JOIN order_items i ON o.order_id = i.order_id
          JOIN books b ON i.book_id = b.book_id)
UNION ALL SELECT 'customers부터 books까지 네 테이블 조인 행 수',
       (SELECT count(*) FROM customers c
          JOIN orders o ON c.customer_id = o.customer_id
          JOIN order_items i ON o.order_id = i.order_id
          JOIN books b ON i.book_id = b.book_id)
UNION ALL SELECT '네 테이블을 전부 LEFT JOIN으로 이었을 때의 행 수',
       (SELECT count(*) FROM customers c
          LEFT JOIN orders o ON c.customer_id = o.customer_id
          LEFT JOIN order_items i ON o.order_id = i.order_id
          LEFT JOIN books b ON i.book_id = b.book_id)
UNION ALL SELECT '부산 손님이 산 책 (네 테이블) 행 수',
       (SELECT count(*) FROM customers c
          JOIN orders o ON c.customer_id = o.customer_id
          JOIN order_items i ON o.order_id = i.order_id
          JOIN books b ON i.book_id = b.book_id
         WHERE c.city = '부산')
UNION ALL SELECT '대구 손님이 산 책 (네 테이블) 행 수',
       (SELECT count(*) FROM customers c
          JOIN orders o ON c.customer_id = o.customer_id
          JOIN order_items i ON o.order_id = i.order_id
          JOIN books b ON i.book_id = b.book_id
         WHERE c.city = '대구')
UNION ALL SELECT '별점 5점 리뷰 (세 테이블) 행 수',
       (SELECT count(*) FROM reviews r
          JOIN books b ON r.book_id = b.book_id
          JOIN customers c ON r.customer_id = c.customer_id
         WHERE r.rating = 5)
UNION ALL SELECT 'reviews-books-customers 세 테이블 조인 행 수',
       (SELECT count(*) FROM reviews r
          JOIN books b ON r.book_id = b.book_id
          JOIN customers c ON r.customer_id = c.customer_id)
UNION ALL SELECT 'order_id와 book_id를 잘못 이은 조인의 행 수',
       (SELECT count(*) FROM orders o
          JOIN order_items i ON o.order_id = i.book_id
          JOIN books b ON i.book_id = b.book_id)
UNION ALL SELECT 'exercise 1 — 한 번도 주문에 담기지 않은 책 수',
       (SELECT count(*) FROM books b
          LEFT JOIN order_items i ON b.book_id = i.book_id
         WHERE i.order_id IS NULL)
UNION ALL SELECT 'exercise 2 — 별점 1~2점 리뷰 (세 테이블) 행 수',
       (SELECT count(*) FROM reviews r
          JOIN books b ON r.book_id = b.book_id
          JOIN customers c ON r.customer_id = c.customer_id
         WHERE r.rating BETWEEN 1 AND 2)
UNION ALL SELECT 'exercise 3 — 과학 분야 책을 산 손님 (네 테이블) 행 수',
       (SELECT count(*) FROM customers c
          JOIN orders o ON c.customer_id = o.customer_id
          JOIN order_items i ON o.order_id = i.order_id
          JOIN books b ON i.book_id = b.book_id
         WHERE b.category = '과학')
UNION ALL SELECT 'exercise 4 — 리뷰가 없는 과학 분야 책 수',
       (SELECT count(*) FROM books b
          LEFT JOIN reviews r ON b.book_id = r.book_id
         WHERE b.category = '과학' AND r.review_id IS NULL)
UNION ALL SELECT 'problem 2 — 어린이 분야 책을 산 손님 (네 테이블) 행 수',
       (SELECT count(*) FROM customers c
          JOIN orders o ON c.customer_id = o.customer_id
          JOIN order_items i ON o.order_id = i.order_id
          JOIN books b ON i.book_id = b.book_id
         WHERE b.category = '어린이')
UNION ALL SELECT 'problem 3 — 상태가 취소인 주문 수',
       (SELECT count(*) FROM orders WHERE status = '취소')
UNION ALL SELECT 'problem 1 채점 포인트 — 주문 없는 고객 중 가입일이 겹치는 날 수',
       (SELECT count(*) FROM (SELECT c.signup_date FROM customers c
                                LEFT JOIN orders o ON c.customer_id = o.customer_id
                               WHERE o.order_id IS NULL
                               GROUP BY c.signup_date HAVING count(*) > 1) t)
UNION ALL SELECT '복습 exercise 채점 포인트 — 별점 5점 리뷰 수',
       (SELECT count(*) FROM reviews WHERE rating = 5)
UNION ALL SELECT '8.1 흔한 실수 — 취소 조건을 WHERE에 건 질의의 행 수 (고객 1~8)',
       (SELECT count(*) FROM customers c
          LEFT JOIN orders o ON c.customer_id = o.customer_id
         WHERE c.customer_id BETWEEN 1 AND 8 AND o.status = '취소')
UNION ALL SELECT '8.1 흔한 실수 — 취소 조건을 ON에 건 질의의 행 수 (고객 1~8)',
       (SELECT count(*) FROM customers c
          LEFT JOIN orders o
            ON c.customer_id = o.customer_id AND o.status = '취소'
         WHERE c.customer_id BETWEEN 1 AND 8)
UNION ALL SELECT '8.2 문제 상황 — 주문 5번을 낸 고객이 부산의 오채원인 경우의 수',
       (SELECT count(*) FROM orders o
          JOIN customers c ON o.customer_id = c.customer_id
         WHERE o.order_id = 5 AND c.name = '오채원' AND c.city = '부산')
UNION ALL SELECT 'orders.status가 널인 행 수 (널을 허용하지 않는 열이다)',
       (SELECT count(*) FROM orders WHERE status IS NULL)
UNION ALL SELECT 'reviews.comment가 널인 행 수 (널을 허용하는 열이다)',
       (SELECT count(*) FROM reviews WHERE comment IS NULL)
UNION ALL SELECT 'customers와 books를 직접 잇는 외래키 수',
       (SELECT count(*) FROM pg_constraint
         WHERE contype = 'f'
           AND ((conrelid = 'customers'::regclass
                 AND confrelid = 'books'::regclass)
             OR (conrelid = 'books'::regclass
                 AND confrelid = 'customers'::regclass)))
UNION ALL SELECT 'exercise 3 채점 포인트 — 과학 책이 둘 이상 담긴 주문 수',
       (SELECT count(*) FROM (SELECT i.order_id FROM order_items i
                                JOIN books b ON i.book_id = b.book_id
                               WHERE b.category = '과학'
                               GROUP BY i.order_id HAVING count(*) > 1) t)
UNION ALL SELECT 'problem 2 채점 포인트 — 어린이 책이 둘 이상 담긴 주문 수',
       (SELECT count(*) FROM (SELECT i.order_id FROM order_items i
                                JOIN books b ON i.book_id = b.book_id
                               WHERE b.category = '어린이'
                               GROUP BY i.order_id HAVING count(*) > 1) t);
