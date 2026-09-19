-- 3장 «도전하기» problem 2 해설: 매출 상위 세 분류와 분류별 판매 상위 두 권
WITH category_revenue AS (
    SELECT
        books.category AS 분류,
        sum(order_items.unit_price * order_items.quantity) AS 매출
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    INNER JOIN books ON order_items.book_id = books.book_id
    WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
        AND orders.status <> '취소'
    GROUP BY books.category
    ORDER BY 매출 DESC
    LIMIT 3
)
SELECT
    category_revenue.분류,
    category_revenue.매출,
    top_books.title AS 제목,
    top_books.권수
FROM category_revenue
CROSS JOIN LATERAL (
    SELECT books.title, sum(order_items.quantity) AS 권수
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    INNER JOIN books ON order_items.book_id = books.book_id
    WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
        AND orders.status <> '취소'
        AND books.category = category_revenue.분류
    GROUP BY books.book_id, books.title
    ORDER BY sum(order_items.quantity) DESC, books.book_id
    LIMIT 2
) AS top_books
ORDER BY category_revenue.매출 DESC, top_books.권수 DESC;
