-- 5장 «도전하기» problem 1 해설: 분야마다 많이 팔린 상위 두 등
WITH book_sales AS (
    SELECT
        books.category AS 분야,
        books.title AS 제목,
        sum(order_items.quantity) AS 판매권수
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    INNER JOIN books ON order_items.book_id = books.book_id
    WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
        AND orders.status <> '취소'
    GROUP BY books.category, books.title
),
ranked AS (
    SELECT
        분야,
        제목,
        판매권수,
        rank() OVER (PARTITION BY 분야 ORDER BY 판매권수 DESC) AS 순위
    FROM book_sales
)
SELECT 분야, 순위, 제목, 판매권수
FROM ranked
WHERE 순위 <= 2
ORDER BY 분야, 순위, 제목;
