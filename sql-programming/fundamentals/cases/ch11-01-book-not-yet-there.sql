-- 11.1 문제 상황 — 새로 들여온 책이 아직 books에 없다
SELECT book_id AS 도서번호, title AS 제목, price AS 가격
FROM books
WHERE title = '빛나는 계절';
