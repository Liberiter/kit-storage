-- 2장 «복습 exercise» 3 해설 (앞 코스 10장 — 집합 연산)
SELECT book_id AS 도서번호
FROM books
EXCEPT
SELECT book_id
FROM order_items
ORDER BY 도서번호;
