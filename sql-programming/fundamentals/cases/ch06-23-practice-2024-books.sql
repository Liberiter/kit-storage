-- 6.2 practice 2 풀이: 2024년에 펴낸 책 (형변환 + LIKE)
SELECT title, published_date
FROM books
WHERE CAST(published_date AS text) LIKE '2024%'
ORDER BY published_date, book_id;
