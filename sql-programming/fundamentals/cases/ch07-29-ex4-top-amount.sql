-- exercise 4 해설: 금액이 가장 큰 주문 항목 다섯 줄 (6장 계산 + 4장 정렬)
SELECT
    order_items.order_id,
    books.title,
    books.category,
    order_items.quantity * order_items.unit_price AS 금액
FROM order_items
INNER JOIN books ON order_items.book_id = books.book_id
ORDER BY 금액 DESC, order_items.order_id
LIMIT 5;
