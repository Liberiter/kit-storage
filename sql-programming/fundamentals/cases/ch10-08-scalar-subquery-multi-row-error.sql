-- 10.1 왜 그럴까요: 여러 행을 내놓는 서브쿼리를 =의 오른쪽에 놓으면 오류 (exit 3)
SELECT title AS 제목
FROM books
WHERE price = (SELECT price FROM books WHERE category = '과학');
