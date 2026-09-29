-- runner: reset
-- 10장 «복습 exercise» 1 해설 (3장): 뷰를 LATERAL 안에서 불러 분류마다 매출 상위 두 권
CREATE VIEW book_sales AS
SELECT
    books.book_id,
    books.title,
    books.category,
    sum(order_items.unit_price * order_items.quantity) AS revenue
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
INNER JOIN books ON order_items.book_id = books.book_id
WHERE orders.status <> '취소'
GROUP BY books.book_id, books.title, books.category;

SELECT
    categories.name AS 분류,
    top_books.title AS 제목,
    top_books.revenue AS 매출
FROM categories
CROSS JOIN LATERAL (
    SELECT book_sales.title, book_sales.revenue
    FROM book_sales
    WHERE book_sales.category = categories.name
    ORDER BY book_sales.revenue DESC, book_sales.book_id
    LIMIT 2
) AS top_books
ORDER BY categories.category_id, top_books.revenue DESC;
