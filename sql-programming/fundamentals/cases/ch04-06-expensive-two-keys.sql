-- 4장 4.1 따라 하기 6단계: 2차 정렬 키로 동점을 가른다 (정가 내림차순, 쪽수 내림차순)
SELECT title, price, page_count
FROM books
WHERE price >= 41000
ORDER BY price DESC, page_count DESC;
