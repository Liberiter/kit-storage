-- exercise 4 해설: 한 번도 주문되지 않은 책을 EXCEPT로 뽑는다
SELECT book_id AS 도서번호
FROM books
EXCEPT
SELECT book_id
FROM order_items
ORDER BY 도서번호
LIMIT 5;
