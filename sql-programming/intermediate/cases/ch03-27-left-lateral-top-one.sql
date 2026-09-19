-- 3장 3.3 «따라 하기» 2단계: LEFT JOIN LATERAL 로 책이 없는 분류도 남긴다
SELECT
    categories.name AS 분류,
    top_books.title AS 제목,
    top_books.price AS 가격
FROM categories
LEFT JOIN LATERAL (
    SELECT books.title, books.price
    FROM books
    WHERE books.category = categories.name
    ORDER BY books.price DESC, books.book_id
    LIMIT 1
) AS top_books ON TRUE
ORDER BY categories.category_id;
