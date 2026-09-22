-- 5장 5.3 «흔한 실수»: 비중의 분모에 ORDER BY 를 넣으면 분모가 누적이 된다
WITH category_revenue AS (
    SELECT
        books.category AS 분야,
        sum(order_items.unit_price * order_items.quantity) AS 매출
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    INNER JOIN books ON order_items.book_id = books.book_id
    WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
        AND orders.status <> '취소'
    GROUP BY books.category
)
SELECT
    분야,
    매출,
    round(100.0 * 매출 / sum(매출) OVER (ORDER BY 매출 DESC), 1) AS "비중(%)"
FROM category_revenue
ORDER BY 매출 DESC, 분야;
