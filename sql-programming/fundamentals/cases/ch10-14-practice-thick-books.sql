-- 10.1 practice 1 풀이: 평균 쪽수보다 두꺼운 책 다섯 권
SELECT book_id AS 도서번호, title AS 제목, page_count AS 쪽수
FROM books
WHERE page_count > (SELECT avg(page_count) FROM books)
ORDER BY page_count DESC, book_id
LIMIT 5;
