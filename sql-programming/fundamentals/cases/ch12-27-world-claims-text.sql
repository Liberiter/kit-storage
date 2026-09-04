-- 주장 케이스 — 12장 본문이 인용하는 world 글자 주장(책 제목·손님 이름)을 고정한다.
-- 실측값이 글자이므로 수치 주장 케이스(ch12-26)와 나눈다 (검증 케이스 규약).
SELECT '1번 책의 제목' AS 주장, title AS 실측값 FROM books WHERE book_id = 1
UNION ALL SELECT '3번 책의 제목', title FROM books WHERE book_id = 3
UNION ALL SELECT '100번 책의 제목', title FROM books WHERE book_id = 100
UNION ALL SELECT '106번 책의 제목', title FROM books WHERE book_id = 106
UNION ALL SELECT '51번 손님의 이름', name FROM customers WHERE customer_id = 51
ORDER BY 주장;
