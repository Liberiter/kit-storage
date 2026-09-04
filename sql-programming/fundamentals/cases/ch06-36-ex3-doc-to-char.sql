-- exercise 3 해설 (문서 탐색 S1.4): to_char 서식 패턴 YYYY-MM-DD (Dy)
SELECT title, to_char(published_date, 'YYYY-MM-DD (Dy)') AS 출간일
FROM books
ORDER BY book_id
LIMIT 5;
