-- 10.1 문제 상황 2단계: 앞에서 받은 평균을 손으로 옮겨 적어 다시 묻는다
SELECT book_id AS 도서번호, title AS 제목, price AS 가격
FROM books
WHERE price > 23539.0625
ORDER BY price DESC, book_id
LIMIT 5;
