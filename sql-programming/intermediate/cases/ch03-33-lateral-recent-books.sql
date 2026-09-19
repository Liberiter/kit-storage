-- 3장 3.3 «practice» 1: 분류마다 가장 최근에 나온 책 두 권
SELECT
    categories.name AS 분류,
    recent_books.title AS 제목,
    recent_books.published_date AS 출간일
FROM categories
CROSS JOIN LATERAL (
    SELECT books.title, books.published_date
    FROM books
    WHERE books.category = categories.name
    ORDER BY books.published_date DESC, books.book_id
    LIMIT 2
) AS recent_books
ORDER BY categories.category_id, recent_books.published_date DESC;
