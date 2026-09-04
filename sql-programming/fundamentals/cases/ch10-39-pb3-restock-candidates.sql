-- problem 3 해설: 재고가 평균보다 적고 리뷰가 달린 책 (스칼라 서브쿼리 + IN 서브쿼리)
SELECT book_id AS 도서번호, title AS 제목, stock AS 재고
FROM books
WHERE stock < (SELECT avg(stock) FROM books)
    AND book_id IN (SELECT book_id FROM reviews)
ORDER BY book_id
LIMIT 5;
