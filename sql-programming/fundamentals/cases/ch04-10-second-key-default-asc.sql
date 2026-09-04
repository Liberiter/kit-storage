-- 4장 4.1 흔한 실수: ORDER BY price DESC, page_count의 둘째 키는 DESC가 아니라 ASC다
SELECT title, price, page_count
FROM books
WHERE price >= 41000
ORDER BY price DESC, page_count;
