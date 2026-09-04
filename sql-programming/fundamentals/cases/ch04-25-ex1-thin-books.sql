-- 4장 exercise 1 해설: 쪽수가 적은 순으로 상위 5종
SELECT title, page_count FROM books ORDER BY page_count, book_id LIMIT 5;
