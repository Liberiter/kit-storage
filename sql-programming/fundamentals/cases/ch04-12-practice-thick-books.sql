-- 4장 4.1 practice 1 풀이: 750쪽 이상 도서를 쪽수 많은 순, 같은 쪽수면 정가 비싼 순으로
SELECT title, page_count, price
FROM books
WHERE page_count >= 750
ORDER BY page_count DESC, price DESC;
