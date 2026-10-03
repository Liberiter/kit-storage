-- 8장 8.2 «따라 하기» 4단계: 전체 합계를 다른 길로 센 값과 맞춰 본다
SELECT sum(quantity) AS 판매권수합계 FROM order_items;

SELECT sum(order_items.quantity) AS 판매권수합계
FROM books
LEFT JOIN order_items ON books.book_id = order_items.book_id
LEFT JOIN reviews ON books.book_id = reviews.book_id;

WITH sold AS (
    SELECT book_id, sum(quantity) AS 판매권수 FROM order_items GROUP BY book_id
)
SELECT sum(sold.판매권수) AS 판매권수합계
FROM books
LEFT JOIN sold ON books.book_id = sold.book_id;
