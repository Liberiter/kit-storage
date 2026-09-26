-- 8장 8.2 «따라 하기» 2단계: 묶기 전의 줄 — 6번 책은 주문 항목 다섯 줄에 같은 리뷰가 다섯 번 붙는다
SELECT
    order_items.order_id AS 주문번호,
    order_items.quantity AS 수량,
    reviews.review_id AS 리뷰번호,
    reviews.rating AS 별점
FROM books
LEFT JOIN order_items ON books.book_id = order_items.book_id
LEFT JOIN reviews ON books.book_id = reviews.book_id
WHERE books.book_id = 6
ORDER BY order_items.order_id;
