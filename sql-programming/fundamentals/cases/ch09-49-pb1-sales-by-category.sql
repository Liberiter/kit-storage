-- problem 1 해설: 분야별 매출 상위 세 분야
SELECT
    books.category AS 분야,
    sum(order_items.unit_price * order_items.quantity) AS 매출
FROM order_items
INNER JOIN books ON order_items.book_id = books.book_id
GROUP BY books.category
ORDER BY 매출 DESC
LIMIT 3;
