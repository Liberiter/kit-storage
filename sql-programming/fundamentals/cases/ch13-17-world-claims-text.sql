-- 주장 케이스 — 13장 exit assessment 본문이 이름으로 부르는 책 제목을 고정한다.
-- 실측값이 글자이므로 수치 주장 케이스(ch13-16)와 나눈다 (검증 케이스 규약).
SELECT '97번 책의 제목' AS 주장, title AS 실측값 FROM books WHERE book_id = 97
UNION ALL SELECT '108번 책의 제목', title FROM books WHERE book_id = 108
ORDER BY 주장;
