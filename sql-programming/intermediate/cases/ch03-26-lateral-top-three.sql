-- 3장 3.3 «따라 하기» 1단계: 분류마다 비싼 책 세 권을 LATERAL 로 뽑는다
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
    LIMIT 3
) AS top_books
ORDER BY categories.category_id, top_books.price DESC;
