-- 3장 «도전하기» problem 3 해설: 분류마다 안 팔린 책의 수와 그중 재고가 가장 많은 책
WITH unsold AS (
    SELECT books.book_id, books.title, books.category, books.stock
    FROM books
    WHERE NOT EXISTS (
        SELECT 1
        FROM order_items
        WHERE order_items.book_id = books.book_id
    )
)
SELECT
    categories.name AS 분류,
    unsold_count.권수,
    top_stock.title AS "재고가 가장 많은 책",
    top_stock.stock AS 재고
FROM categories
CROSS JOIN LATERAL (
    SELECT count(*) AS 권수
    FROM unsold
    WHERE unsold.category = categories.name
) AS unsold_count
LEFT JOIN LATERAL (
    SELECT unsold.title, unsold.stock
    FROM unsold
    WHERE unsold.category = categories.name
    ORDER BY unsold.stock DESC, unsold.book_id
    LIMIT 1
) AS top_stock ON TRUE
ORDER BY categories.category_id;
