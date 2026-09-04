-- 주장 케이스 — 12장 본문이 인용하는 world 수치 주장(정수)을 한 표로 고정한다.
-- 본문에 출력 블록이 없어 러너 대조에서 빠지는 값들이다 (D-017).
SELECT '1번 책의 가격' AS 주장, price AS 실측값 FROM books WHERE book_id = 1
UNION ALL SELECT '3번 책의 가격', price FROM books WHERE book_id = 3
UNION ALL SELECT '3번 책의 재고', stock FROM books WHERE book_id = 3
UNION ALL SELECT '100번 책의 가격', price FROM books WHERE book_id = 100
UNION ALL SELECT '100번 책의 재고', stock FROM books WHERE book_id = 100
UNION ALL SELECT '106번 책의 재고', stock FROM books WHERE book_id = 106
UNION ALL SELECT '249번 책의 재고', stock FROM books WHERE book_id = 249
UNION ALL SELECT '도서번호가 1인 책', count(*) FROM books WHERE book_id = 1
UNION ALL SELECT '도서번호가 249인 책', count(*) FROM books WHERE book_id = 249
UNION ALL SELECT '도서번호가 99999인 책', count(*) FROM books
    WHERE book_id = 99999
UNION ALL SELECT '제목이 빛나는 계절인 책', count(*) FROM books
    WHERE title = '빛나는 계절'
UNION ALL SELECT '4번 주문 중 상태가 취소인 것', count(*) FROM orders
    WHERE order_id = 4 AND status = '취소'
UNION ALL SELECT '4번 주문의 항목 수', count(*) FROM order_items
    WHERE order_id = 4
UNION ALL SELECT '4번 주문에 담긴 249번 책의 수량', quantity FROM order_items
    WHERE order_id = 4 AND book_id = 249
UNION ALL SELECT '28번 주문의 항목 수', count(*) FROM order_items
    WHERE order_id = 28
UNION ALL SELECT '28번 주문 중 상태가 취소인 것', count(*) FROM orders
    WHERE order_id = 28 AND status = '취소'
UNION ALL SELECT '45번 주문 중 상태가 취소인 것', count(*) FROM orders
    WHERE order_id = 45 AND status = '취소'
UNION ALL SELECT '620번 주문의 항목 수', count(*) FROM order_items
    WHERE order_id = 620
UNION ALL SELECT '620번 주문에 담긴 106번 책의 수량', quantity FROM order_items
    WHERE order_id = 620 AND book_id = 106
UNION ALL SELECT 'orders의 가장 큰 주문번호', max(order_id) FROM orders
ORDER BY 주장;
