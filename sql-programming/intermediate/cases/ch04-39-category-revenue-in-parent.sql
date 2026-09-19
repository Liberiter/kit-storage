-- 4장 «연습하기» exercise 4 해설: 상위 분류 안에서의 매출 비중
WITH category_revenue AS (
    SELECT
        parent.name AS 상위분류,
        child.name AS 분야,
        sum(order_items.unit_price * order_items.quantity) AS 매출
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    INNER JOIN books ON order_items.book_id = books.book_id
    INNER JOIN categories AS child ON books.category = child.name
    INNER JOIN categories AS parent ON child.parent_id = parent.category_id
    WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
        AND orders.status <> '취소'
    GROUP BY parent.name, child.name
)
SELECT
    상위분류,
    분야,
    매출,
    round(100.0 * 매출 / sum(매출) OVER (PARTITION BY 상위분류), 1)
        AS "비중(%)"
FROM category_revenue
ORDER BY 상위분류, 매출 DESC;
