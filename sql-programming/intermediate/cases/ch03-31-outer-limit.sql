-- 3장 3.3 «흔한 실수»: LIMIT 을 바깥에 두면 분류마다가 아니라 전체에서 자른다
SELECT
    categories.name AS 분류,
    top_books.title AS 제목,
    top_books.price AS 가격
FROM categories
CROSS JOIN LATERAL (
    SELECT books.title, books.price
    FROM books
    WHERE books.category = categories.name
    ORDER BY books.price DESC, books.book_id
) AS top_books
ORDER BY categories.category_id, top_books.price DESC
LIMIT 3;
