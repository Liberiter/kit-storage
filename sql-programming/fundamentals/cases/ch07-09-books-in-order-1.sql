-- 7.2 따라 하기 2단계: 도서번호를 손으로 들고 books를 다시 조회한다 (3장 IN)
SELECT book_id, title, author, price
FROM books
WHERE book_id IN (29, 176, 292)
ORDER BY book_id;
