-- 3장 3.3 «practice» 2: 분류마다 가장 싼 책 두 권 (책이 없는 분류도 남긴다)
SELECT
    categories.name AS 분류,
    cheap_books.title AS 제목,
    cheap_books.price AS 가격
FROM categories
LEFT JOIN LATERAL (
    SELECT books.title, books.price
    FROM books
    WHERE books.category = categories.name
    ORDER BY books.price, books.book_id
    LIMIT 2
) AS cheap_books ON TRUE
ORDER BY categories.category_id, cheap_books.price;
