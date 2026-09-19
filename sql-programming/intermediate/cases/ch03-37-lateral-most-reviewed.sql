-- 3장 «연습하기» exercise 3 해설: 분류마다 리뷰가 가장 많이 달린 책 두 권
SELECT
    categories.name AS 분류,
    hot_books.title AS 제목,
    hot_books.리뷰수
FROM categories
CROSS JOIN LATERAL (
    SELECT books.title, count(*) AS 리뷰수
    FROM books
    INNER JOIN reviews ON reviews.book_id = books.book_id
    WHERE books.category = categories.name
    GROUP BY books.book_id, books.title
    ORDER BY count(*) DESC, books.book_id
    LIMIT 2
) AS hot_books
ORDER BY categories.category_id, hot_books.리뷰수 DESC;
