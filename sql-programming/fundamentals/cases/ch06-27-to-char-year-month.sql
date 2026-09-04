-- 6.3 따라 하기 4단계: to_char로 날짜를 원하는 모양의 글자로 만든다
SELECT title, published_date, to_char(published_date, 'YYYY년 MM월') AS 출간월
FROM books
ORDER BY book_id
LIMIT 5;
