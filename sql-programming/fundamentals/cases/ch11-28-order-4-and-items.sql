-- 11.3 문제 상황 — 지울 주문과 거기 딸린 주문 항목을 확인한다
SELECT order_id AS 주문번호, order_date AS 주문일, status AS 상태
FROM orders
WHERE order_id = 4;

SELECT order_id AS 주문번호, book_id AS 도서번호, quantity AS 수량
FROM order_items
WHERE order_id = 4
ORDER BY book_id;
