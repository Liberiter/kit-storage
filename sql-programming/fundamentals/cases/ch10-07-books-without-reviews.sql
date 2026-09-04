-- 10.1 따라 하기 5단계: 8장의 "리뷰가 하나도 없는 책"을 NOT IN으로 다시 뽑는다
SELECT book_id AS 도서번호, title AS 제목
FROM books
WHERE book_id NOT IN (SELECT book_id FROM reviews)
ORDER BY book_id
LIMIT 5;
