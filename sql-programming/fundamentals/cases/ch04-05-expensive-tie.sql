-- 4장 4.1 따라 하기 5단계: 정렬 키가 하나뿐일 때 동점 행의 순서 (41000원 이상 11행)
SELECT title, price, page_count
FROM books
WHERE price >= 41000
ORDER BY price DESC;
