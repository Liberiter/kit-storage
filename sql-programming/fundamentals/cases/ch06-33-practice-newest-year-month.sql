-- 6.3 practice 2 풀이: 최신 다섯 종의 출간 연월
SELECT title, to_char(published_date, 'YYYY-MM') AS 출간월
FROM books
ORDER BY published_date DESC, book_id
LIMIT 5;
