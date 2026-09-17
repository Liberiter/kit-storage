-- 1장 1.1 «문제 상황»: orders 한 줄에는 금액 열이 없다
SELECT order_id AS 주문번호, order_date AS 주문일, status AS 상태
FROM orders
WHERE order_id = 5;
