-- 8장 8.2 «왜 그럴까요»: 한 갈래만 잇는 조인은 부풀지 않는다
SELECT books.book_id AS 도서번호, sum(order_items.quantity) AS 판매권수
FROM books
LEFT JOIN order_items ON books.book_id = order_items.book_id
WHERE books.book_id <= 6
GROUP BY books.book_id
ORDER BY books.book_id;
