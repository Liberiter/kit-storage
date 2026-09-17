-- 1장 1.1 «practice» 1: 알갱이를 달에서 분야로 바꾼다
SELECT
    books.category AS 분야,
    sum(order_items.unit_price * order_items.quantity) AS 매출,
    sum(order_items.quantity) AS 판매권수
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
INNER JOIN books ON order_items.book_id = books.book_id
WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
    AND orders.status <> '취소'
GROUP BY books.category
ORDER BY 매출 DESC, 분야;
