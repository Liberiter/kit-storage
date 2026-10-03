-- 13장(exit assessment) 주장 케이스 (글자) — 본문이 이름으로 부르는 책·고객·주문 상태
--   42·97·150번 책의 제목과 저자 → 문항 3 지문의 스프레드시트 「책」·「저자」 칸
--   3·8번 고객의 이름과 이메일 → 문항 3 지문의 스프레드시트 「예약 고객」·「고객 이메일」 칸
--   360번 주문의 상태 → 문항 4 해설 「한승현 고객의 첫 주문 360번은 **취소된** 주문」
SELECT '42번 책 제목' AS 주장, title AS 실측값 FROM books WHERE book_id = 42
UNION ALL
SELECT '42번 책 저자', author FROM books WHERE book_id = 42
UNION ALL
SELECT '97번 책 제목', title FROM books WHERE book_id = 97
UNION ALL
SELECT '97번 책 저자', author FROM books WHERE book_id = 97
UNION ALL
SELECT '150번 책 제목', title FROM books WHERE book_id = 150
UNION ALL
SELECT '150번 책 저자', author FROM books WHERE book_id = 150
UNION ALL
SELECT '3번 고객 이름', name FROM customers WHERE customer_id = 3
UNION ALL
SELECT '3번 고객 이메일', email FROM customers WHERE customer_id = 3
UNION ALL
SELECT '8번 고객 이름', name FROM customers WHERE customer_id = 8
UNION ALL
SELECT '8번 고객 이메일', email FROM customers WHERE customer_id = 8
UNION ALL
SELECT '360번 주문 상태', status FROM orders WHERE order_id = 360;
