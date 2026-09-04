-- 10.1 왜 그럴까요: 널과 견주는 조건은 알 수 없음이 되어 한 행도 남지 않는다
SELECT book_id AS 도서번호, title AS 제목, price AS 가격
FROM books
WHERE price > (SELECT avg(price) FROM books WHERE category = '만화')
ORDER BY book_id
LIMIT 5;
