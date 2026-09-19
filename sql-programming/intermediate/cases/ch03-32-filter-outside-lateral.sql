-- 3장 3.3 «흔한 실수»: 조건을 바깥에 두면 세 권을 고른 «뒤에» 걸러 낸다
SELECT
    categories.name AS 분류,
    top_books.title AS 제목,
    top_books.price AS 가격,
    top_books.stock AS 재고
FROM categories
CROSS JOIN LATERAL (
    SELECT books.title, books.price, books.stock
    FROM books
    WHERE books.category = categories.name
    ORDER BY books.price DESC, books.book_id
    LIMIT 3
) AS top_books
WHERE top_books.stock >= 10
ORDER BY categories.category_id, top_books.price DESC;

SELECT
    categories.name AS 분류,
    top_books.title AS 제목,
    top_books.price AS 가격,
    top_books.stock AS 재고
FROM categories
CROSS JOIN LATERAL (
    SELECT books.title, books.price, books.stock
    FROM books
    WHERE books.category = categories.name
        AND books.stock >= 10
    ORDER BY books.price DESC, books.book_id
    LIMIT 3
) AS top_books
ORDER BY categories.category_id, top_books.price DESC;
