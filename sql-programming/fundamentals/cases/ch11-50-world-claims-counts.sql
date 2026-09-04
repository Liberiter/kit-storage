-- 주장 케이스 — 11장 본문이 인용하는 world 수치 주장(정수)을 한 표로 고정한다.
-- 본문에 출력 블록이 없어 러너 대조에서 빠지는 값들이다 (D-017).
SELECT 'books 행 수' AS 주장, count(*) AS 실측값 FROM books
UNION ALL SELECT 'customers 행 수', count(*) FROM customers
UNION ALL SELECT 'orders 행 수', count(*) FROM orders
UNION ALL SELECT 'order_items 행 수', count(*) FROM order_items
UNION ALL SELECT 'reviews 행 수', count(*) FROM reviews
UNION ALL SELECT 'books의 가장 큰 도서번호', max(book_id) FROM books
UNION ALL SELECT 'customers의 가장 큰 고객번호', max(customer_id) FROM customers
UNION ALL SELECT 'books의 분야 가짓수', count(DISTINCT category) FROM books
UNION ALL SELECT 'books의 열 수', count(*) FROM information_schema.columns
    WHERE table_name = 'books'
UNION ALL SELECT '도서번호가 1인 책', count(*) FROM books WHERE book_id = 1
UNION ALL SELECT '고객번호가 9999인 손님', count(*) FROM customers
    WHERE customer_id = 9999
UNION ALL SELECT '5번 책의 재고', stock FROM books WHERE book_id = 5
UNION ALL SELECT '소설 분야 권수', count(*) FROM books WHERE category = '소설'
UNION ALL SELECT '어린이 분야 권수', count(*) FROM books WHERE category = '어린이'
UNION ALL SELECT '과학 분야 권수', count(*) FROM books WHERE category = '과학'
UNION ALL SELECT '소설 분야 중 재고가 0인 책', count(*) FROM books
    WHERE category = '소설' AND stock = 0
UNION ALL SELECT '여행 분야 권수', count(*) FROM books WHERE category = '여행'
UNION ALL SELECT '여행 분야 중 재고가 5권 미만인 책', count(*) FROM books
    WHERE category = '여행' AND stock < 5
UNION ALL SELECT '별점이 1점인 리뷰', count(*) FROM reviews WHERE rating = 1
UNION ALL SELECT '별점 2점 이하이고 한 줄평이 없는 리뷰', count(*) FROM reviews
    WHERE rating <= 2 AND comment IS NULL
UNION ALL SELECT '취소 상태인 주문', count(*) FROM orders WHERE status = '취소'
UNION ALL SELECT '2024년에 들어온 취소 주문', count(*) FROM orders
    WHERE status = '취소' AND order_date BETWEEN '2024-01-01' AND '2024-12-31'
UNION ALL SELECT '한 번도 주문되지 않은 책', count(*) FROM books
    WHERE book_id NOT IN (SELECT book_id FROM order_items)
UNION ALL SELECT '리뷰가 5건 이상 달린 책', count(*) FROM (
    SELECT book_id FROM reviews GROUP BY book_id HAVING count(*) >= 5
) t
UNION ALL SELECT '리뷰 1번 중 한 줄평이 있는 행', count(comment) FROM reviews
    WHERE review_id = 1
ORDER BY 주장;
