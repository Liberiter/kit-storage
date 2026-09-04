-- 6.2 따라 하기 5단계: 날짜를 글자로 바꾸면 LIKE를 쓸 수 있다
SELECT title, published_date
FROM books
WHERE CAST(published_date AS text) LIKE '2025%'
ORDER BY published_date, book_id;
