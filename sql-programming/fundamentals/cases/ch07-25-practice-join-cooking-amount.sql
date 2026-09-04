-- 7.3 practice 2 풀이: 요리 분야 주문 항목을 금액 큰 순으로
SELECT
    order_items.order_id,
    books.title,
    order_items.quantity * order_items.unit_price AS 금액
FROM order_items
INNER JOIN books ON order_items.book_id = books.book_id
WHERE books.category = '요리'
ORDER BY 금액 DESC, order_items.order_id
LIMIT 5;
