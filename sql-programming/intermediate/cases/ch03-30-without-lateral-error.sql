-- 3장 3.3 «왜 그럴까요»: LATERAL 을 빼면 바깥 열을 참조할 수 없다
SELECT
    categories.name AS 분류,
    top_books.title AS 제목,
    top_books.price AS 가격
FROM categories
CROSS JOIN (
    SELECT books.title, books.price
    FROM books
    WHERE books.category = categories.name
    ORDER BY books.price DESC, books.book_id
    LIMIT 3
) AS top_books
ORDER BY categories.category_id, top_books.price DESC;
