-- runner: reset
-- 10장 10.1 «practice» 1: 분야별 매출 뷰
CREATE VIEW category_sales AS
SELECT
    books.category,
    sum(order_items.unit_price * order_items.quantity) AS revenue,
    sum(order_items.quantity) AS units_sold
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
INNER JOIN books ON order_items.book_id = books.book_id
WHERE orders.status <> '취소'
GROUP BY books.category;

SELECT category AS 분야, revenue AS 매출, units_sold AS 판매권수
FROM category_sales
ORDER BY revenue DESC, category;
