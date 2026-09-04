-- 6.1 따라 하기 1단계: 숫자 타입의 곱셈 (단가 x 수량)
SELECT order_id, book_id, quantity, unit_price, quantity * unit_price AS 금액
FROM order_items
ORDER BY order_id, book_id
LIMIT 5;
