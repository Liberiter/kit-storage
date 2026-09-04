-- 주장 케이스 — 13장 exit assessment 본문이 인용하는 world 수치 주장(정수)을
-- 한 표로 고정한다. 본문에 출력 블록이 없어 러너 대조에서 빠지는 값들이다 (D-017).
SELECT '여행·요리 분야 12000~20000원 책 수' AS 주장, count(*) AS 실측값
    FROM books
    WHERE category IN ('여행', '요리') AND price BETWEEN 12000 AND 20000
UNION ALL SELECT '생일이 널인 고객 수', count(*) FROM customers
    WHERE birth_date IS NULL
UNION ALL SELECT '이름이 서도윤인 고객 수', count(*) FROM customers
    WHERE name = '서도윤'
UNION ALL SELECT '춘천에 사는 이름이 조도윤인 고객 수', count(*) FROM customers
    WHERE city = '춘천' AND name = '조도윤'
UNION ALL SELECT '고객이 사는 도시의 가짓수', count(DISTINCT city) FROM customers
UNION ALL SELECT '별점 5점 리뷰 수', count(*) FROM reviews WHERE rating = 5
UNION ALL SELECT '별점 5점이면서 구매 인증이 없는 리뷰 수', count(*) FROM reviews
    WHERE rating = 5 AND order_id IS NULL
UNION ALL SELECT '별점 1점 리뷰 수', count(*) FROM reviews WHERE rating = 1
UNION ALL SELECT '별점 2점 리뷰 수', count(*) FROM reviews WHERE rating = 2
UNION ALL SELECT '상태가 배송완료인 주문 수', count(*) FROM orders
    WHERE status = '배송완료'
UNION ALL SELECT '97번 책의 정가', price FROM books WHERE book_id = 97
UNION ALL SELECT '97번 책의 재고', stock FROM books WHERE book_id = 97
UNION ALL SELECT '108번 책의 정가', price FROM books WHERE book_id = 108
UNION ALL SELECT '108번 책의 재고', stock FROM books WHERE book_id = 108
UNION ALL SELECT '가장 큰 고객번호', max(customer_id) FROM customers
UNION ALL SELECT '가장 큰 주문번호', max(order_id) FROM orders
UNION ALL SELECT '이메일이 siyun.nam@bookmail.kr인 고객 수', count(*)
    FROM customers WHERE email = 'siyun.nam@bookmail.kr'
ORDER BY 주장;
