-- 9장 본문이 인용하는 world 수치 주장. 각 행이 "주장 → 실측값(개수)" 쌍이다.
-- 출력 블록이 없어 러너 대조에서 빠지는 주장들을 여기서 고정한다 (D-017·D-021).
--  · 들어가며·9.1 문제 상황: books 320권, 과학 분야 29권, reviews 520건,
--    customers 150명, orders 620건, order_items 1,243행
--  · 9.1 따라 하기 5단계·왜 그럴까요: comment가 널인 리뷰 189건,
--    shipped_date가 널인 주문 144건
--  · 9.2 문제 상황: 분야는 여덟 가지라 질의를 여덟 번 되풀이해야 한다
--  · 9.1 따라 하기 4단계: 주문 5번의 항목은 두 줄이다 (8장 8.2 문제 상황)
--  · 9.3 개념의 절 차례 그림: customers INNER JOIN orders 620행
--  · 9.2 따라 하기 4단계·흔한 실수: customers LEFT JOIN orders 649행,
--    주문이 하나도 없는 고객 29명
--  · 9.2 practice 1·9.3 practice 2·exercise 4: 도시는 열 곳이고, 그중 고객이
--    15명 이상인 곳은 다섯, 배송완료 주문이 50건 이상인 곳은 셋이다
--  · 9.3 따라 하기 4단계·practice 1·problem 2: 리뷰가 4건 이상인 책 31권,
--    5건 이상인 책 14권
--  · exercise 3: 리뷰가 하나도 없는 책 76권
--  · problem 1: 분야는 여덟 가지이고 그중 셋만 싣는다
--  · problem 3: 고객 1~8번 중 리뷰가 하나도 없는 손님 3명
--  · 9.1 practice 1: reviews.rating에는 널이 없다
--  · 9.2 따라 하기 4단계: 이름이 겹치는 손님이 있다(동명이인 이름 31가지)
--  · 9.2 왜 그럴까요: 제목이 같은 책은 하나도 없어 분야·제목 조합은 320가지다
--  · 9.2 개념: 도식에 적은 (분야, 가격) 세 조합이 실제 books의 행이다
--  · 9.3 따라 하기 4단계: 리뷰가 한 건뿐이고 그 별점이 5점인 책이 있다
--  · 9.1 따라 하기 3단계: 과학 분야 평균 가격의 소수점 아래는 열두 자리다
SELECT 'books 행 수' AS claim, count(*) AS value FROM books
UNION ALL SELECT 'customers 행 수', count(*) FROM customers
UNION ALL SELECT 'orders 행 수', count(*) FROM orders
UNION ALL SELECT 'order_items 행 수', count(*) FROM order_items
UNION ALL SELECT 'reviews 행 수', count(*) FROM reviews
UNION ALL SELECT '과학 분야 책 수',
       (SELECT count(*) FROM books WHERE category = '과학')
UNION ALL SELECT 'comment가 널인 리뷰 수',
       (SELECT count(*) FROM reviews WHERE comment IS NULL)
UNION ALL SELECT 'shipped_date가 널인 주문 수',
       (SELECT count(*) FROM orders WHERE shipped_date IS NULL)
UNION ALL SELECT 'books.category의 가짓수',
       (SELECT count(*) FROM (SELECT category FROM books
                               GROUP BY category) t)
UNION ALL SELECT 'customers.city의 가짓수',
       (SELECT count(*) FROM (SELECT city FROM customers GROUP BY city) t)
UNION ALL SELECT '주문 5번의 항목 수',
       (SELECT count(*) FROM order_items WHERE order_id = 5)
UNION ALL SELECT 'customers INNER JOIN orders 행 수',
       (SELECT count(*) FROM customers c
          JOIN orders o ON c.customer_id = o.customer_id)
UNION ALL SELECT 'customers LEFT JOIN orders 행 수',
       (SELECT count(*) FROM customers c
          LEFT JOIN orders o ON c.customer_id = o.customer_id)
UNION ALL SELECT '주문이 하나도 없는 고객 수',
       (SELECT count(*) FROM customers c
          LEFT JOIN orders o ON c.customer_id = o.customer_id
         WHERE o.order_id IS NULL)
UNION ALL SELECT '리뷰가 4건 이상 달린 책 수',
       (SELECT count(*) FROM (SELECT book_id FROM reviews
                               GROUP BY book_id HAVING count(*) >= 4) t)
UNION ALL SELECT '리뷰가 5건 이상 달린 책 수',
       (SELECT count(*) FROM (SELECT book_id FROM reviews
                               GROUP BY book_id HAVING count(*) >= 5) t)
UNION ALL SELECT '리뷰가 하나도 없는 책 수',
       (SELECT count(*) FROM books b
          LEFT JOIN reviews r ON b.book_id = r.book_id
         WHERE r.review_id IS NULL)
UNION ALL SELECT '고객 1~8번 중 리뷰가 하나도 없는 손님 수',
       (SELECT count(*) FROM (SELECT c.customer_id FROM customers c
                                LEFT JOIN reviews r
                                  ON c.customer_id = r.customer_id
                               WHERE c.customer_id BETWEEN 1 AND 8
                               GROUP BY c.customer_id
                              HAVING count(r.review_id) = 0) t)
UNION ALL SELECT '주문이 20건 이상인 고객 수',
       (SELECT count(*) FROM (SELECT customer_id FROM orders
                               GROUP BY customer_id HAVING count(*) >= 20) t)
UNION ALL SELECT '2026년 이후 주문이 6건 이상인 고객 수',
       (SELECT count(*) FROM (SELECT customer_id FROM orders
                               WHERE order_date >= '2026-01-01'
                               GROUP BY customer_id HAVING count(*) >= 6) t)
UNION ALL SELECT '평균 가격이 24,000원 이상인 분야 수',
       (SELECT count(*) FROM (SELECT category FROM books
                               GROUP BY category
                              HAVING avg(price) >= 24000) t)
UNION ALL SELECT '배송완료 주문 수',
       (SELECT count(*) FROM orders WHERE status = '배송완료')
UNION ALL SELECT '고객이 15명 이상인 도시 수',
       (SELECT count(*) FROM (SELECT city FROM customers
                               GROUP BY city HAVING count(*) >= 15) t)
UNION ALL SELECT '배송완료 주문이 50건 이상인 도시 수',
       (SELECT count(*) FROM (SELECT c.city FROM customers c
                                JOIN orders o ON c.customer_id = o.customer_id
                               WHERE o.status = '배송완료'
                               GROUP BY c.city HAVING count(*) >= 50) t)
UNION ALL SELECT '고객 85번의 주문 수',
       (SELECT count(*) FROM orders WHERE customer_id = 85)
UNION ALL SELECT 'rating이 널인 리뷰 수 (널을 허용하지 않는 열이다)',
       (SELECT count(*) FROM reviews WHERE rating IS NULL)
UNION ALL SELECT '둘 이상이 같이 쓰는 고객 이름의 가짓수',
       (SELECT count(*) FROM (SELECT name FROM customers
                               GROUP BY name HAVING count(*) > 1) t)
UNION ALL SELECT '제목이 겹치는 책 제목의 가짓수',
       (SELECT count(*) FROM (SELECT title FROM books
                               GROUP BY title HAVING count(*) > 1) t)
UNION ALL SELECT 'category와 title의 조합 가짓수',
       (SELECT count(*) FROM (SELECT category, title FROM books
                               GROUP BY category, title) t)
UNION ALL SELECT '9.2 개념 도식에 적은 (분야, 가격) 세 조합에 해당하는 책 수',
       (SELECT count(*) FROM books
         WHERE (category = '소설' AND price IN (21000, 13000))
            OR (category = '과학' AND price = 9500))
UNION ALL SELECT '리뷰가 한 건뿐이고 그 별점이 5점인 책 수',
       (SELECT count(*) FROM (SELECT book_id FROM reviews
                               GROUP BY book_id
                              HAVING count(*) = 1 AND min(rating) = 5) t)
UNION ALL SELECT '과학 분야 평균 가격의 소수점 아래 자릿수',
       (SELECT length(split_part(CAST(avg(price) AS text), '.', 2))
          FROM books WHERE category = '과학');
