-- 8장 «연습하기» exercise 3 해설: 분류별 판매 권수와 리뷰 수 — 두 갈래를 따로 센 뒤 잇는다
WITH sold AS (
    SELECT books.category, sum(order_items.quantity) AS 판매권수
    FROM books
    INNER JOIN order_items ON books.book_id = order_items.book_id
    GROUP BY books.category
),
reviewed AS (
    SELECT books.category, count(*) AS 리뷰수
    FROM books
    INNER JOIN reviews ON books.book_id = reviews.book_id
    GROUP BY books.category
)
SELECT sold.category AS 분류, sold.판매권수, reviewed.리뷰수
FROM sold
INNER JOIN reviewed ON sold.category = reviewed.category
ORDER BY sold.category;
