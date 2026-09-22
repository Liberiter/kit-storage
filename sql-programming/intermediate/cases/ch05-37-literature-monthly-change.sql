-- 5장 «연습하기» exercise 2 해설: 분야 안에서의 전월 대비 증감
WITH category_monthly AS (
    SELECT
        books.category AS 분야,
        to_char(orders.order_date, 'YYYY-MM') AS 주문월,
        sum(order_items.unit_price * order_items.quantity) AS 매출
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    INNER JOIN books ON order_items.book_id = books.book_id
    WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
        AND orders.status <> '취소'
        AND books.category IN ('소설', '에세이')
    GROUP BY books.category, to_char(orders.order_date, 'YYYY-MM')
),
with_prev AS (
    SELECT
        분야,
        주문월,
        매출,
        lag(매출) OVER (PARTITION BY 분야 ORDER BY 주문월) AS 전월매출
    FROM category_monthly
)
SELECT 분야, 주문월, 매출, 매출 - 전월매출 AS 증감
FROM with_prev
ORDER BY 분야, 주문월;
