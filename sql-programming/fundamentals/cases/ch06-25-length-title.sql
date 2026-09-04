-- 6.3 따라 하기 2단계: length로 제목의 글자 수를 센다
SELECT title, length(title) AS 글자수 FROM books ORDER BY book_id LIMIT 5;
