-- 6.1 practice 1 풀이: 금액이 큰 주문 항목 다섯 줄
SELECT order_id, book_id, quantity, unit_price, quantity * unit_price AS 금액
FROM order_items
ORDER BY 금액 DESC, order_id, book_id
LIMIT 5;
