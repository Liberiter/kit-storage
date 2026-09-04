-- 4장 problem 3 (b) 해설: 2차·3차 정렬 키로 순서를 고정한 질의
SELECT title, stock, price
FROM books
WHERE category = '어린이'
ORDER BY stock, price, book_id
LIMIT 5;
