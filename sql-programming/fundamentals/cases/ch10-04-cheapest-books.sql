-- 10.1 따라 하기 2단계: 9장이 미뤄 둔 "가장 싼 책의 제목"을 한 번에 뽑는다
SELECT book_id AS 도서번호, title AS 제목, price AS 가격
FROM books
WHERE price = (SELECT min(price) FROM books)
ORDER BY book_id;
