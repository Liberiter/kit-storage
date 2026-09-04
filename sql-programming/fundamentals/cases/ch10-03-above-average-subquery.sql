-- 10.1 따라 하기 1단계: 평균을 구하는 질의를 통째로 조건 자리에 놓는다.
-- 10.1 개념의 서식 규칙 예제(R33)와 입력이 같다(그 자리는 출력을 싣지 않는다).
SELECT book_id AS 도서번호, title AS 제목, price AS 가격
FROM books
WHERE price > (SELECT avg(price) FROM books)
ORDER BY price DESC, book_id
LIMIT 5;
