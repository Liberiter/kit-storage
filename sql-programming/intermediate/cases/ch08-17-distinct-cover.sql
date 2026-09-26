-- 8장 8.2 «따라 하기» 5단계: DISTINCT 로 덮으면 키를 센 칸은 맞고 값을 더한 칸은 틀린다
SELECT
    books.book_id AS 도서번호,
    sum(DISTINCT order_items.quantity) AS 판매권수,
    count(DISTINCT reviews.review_id) AS 리뷰수
FROM books
LEFT JOIN order_items ON books.book_id = order_items.book_id
LEFT JOIN reviews ON books.book_id = reviews.book_id
WHERE books.book_id <= 6
GROUP BY books.book_id
ORDER BY books.book_id;
