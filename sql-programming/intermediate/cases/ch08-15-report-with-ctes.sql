-- 8장 8.2 «따라 하기» 3단계: 질문마다 CTE 로 따로 센 뒤 책에 잇는다
WITH sold AS (
    SELECT book_id, sum(quantity) AS 판매권수
    FROM order_items
    GROUP BY book_id
),
reviewed AS (
    SELECT book_id, count(*) AS 리뷰수, round(avg(rating), 2) AS 평균별점
    FROM reviews
    GROUP BY book_id
)
SELECT
    books.book_id AS 도서번호,
    sold.판매권수,
    COALESCE(reviewed.리뷰수, 0) AS 리뷰수,
    reviewed.평균별점
FROM books
LEFT JOIN sold ON books.book_id = sold.book_id
LEFT JOIN reviewed ON books.book_id = reviewed.book_id
WHERE books.book_id <= 6
ORDER BY books.book_id;
