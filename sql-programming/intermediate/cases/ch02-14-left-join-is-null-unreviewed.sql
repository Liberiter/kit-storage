-- 2장 2.2 «따라 하기» 2단계 — 앞 코스 8장의 LEFT JOIN + IS NULL 로 같은 답을
-- 낸다 (ch02-13 과 기대 출력이 바이트 동일하다)
SELECT books.book_id AS 도서번호, books.title AS 제목
FROM books
LEFT JOIN reviews ON books.book_id = reviews.book_id
WHERE reviews.review_id IS NULL
ORDER BY books.book_id
LIMIT 5;
