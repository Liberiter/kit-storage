-- exercise 3 (문서 탐색) 해설: 모든 과학책보다 비싼 책 (> ALL, 공식 문서 9.24.5)
SELECT book_id AS 도서번호, title AS 제목, category AS 분야, price AS 가격
FROM books
WHERE price > ALL (SELECT price FROM books WHERE category = '과학')
ORDER BY price DESC, book_id;
