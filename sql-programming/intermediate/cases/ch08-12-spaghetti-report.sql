-- 8장 8.2 «문제 상황»: 판매 권수·리뷰 수·평균 별점을 한 질의에 몰아넣은 보고서 (스파게티 질의)
SELECT
    books.book_id AS 도서번호,
    sum(order_items.quantity) AS 판매권수,
    count(reviews.review_id) AS 리뷰수,
    round(avg(reviews.rating), 2) AS 평균별점
FROM books
LEFT JOIN order_items ON books.book_id = order_items.book_id
LEFT JOIN reviews ON books.book_id = reviews.book_id
WHERE books.book_id <= 6
GROUP BY books.book_id
ORDER BY books.book_id;
