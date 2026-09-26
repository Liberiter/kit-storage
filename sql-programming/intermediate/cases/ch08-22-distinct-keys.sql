-- 8장 8.2 «practice» 2: 곱해진 줄에서도 키를 DISTINCT 로 세면 맞는다
SELECT
    books.book_id AS 도서번호,
    count(DISTINCT order_items.order_id) AS 주문건수,
    count(DISTINCT reviews.review_id) AS 리뷰수
FROM books
LEFT JOIN order_items ON books.book_id = order_items.book_id
LEFT JOIN reviews ON books.book_id = reviews.book_id
WHERE books.book_id <= 6
GROUP BY books.book_id
ORDER BY books.book_id;
