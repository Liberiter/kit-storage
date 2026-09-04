-- runner: reset
-- 13장 exit assessment 문항 14 (가) 해설: 신규 손님 등록과 첫 주문을 한 덩어리로
BEGIN;
INSERT INTO customers (name, email, city, signup_date, marketing_opt_in)
VALUES ('남시윤', 'siyun.nam@bookmail.kr', '제주', '2026-08-29', TRUE);
INSERT INTO orders (customer_id, order_date, status)
VALUES ((SELECT max(customer_id) FROM customers), '2026-08-29', '배송준비');
INSERT INTO order_items (order_id, book_id, quantity, unit_price)
VALUES
    ((SELECT max(order_id) FROM orders), 97, 1, 16000),
    ((SELECT max(order_id) FROM orders), 108, 2, 12000);
UPDATE books SET stock = stock - 1 WHERE book_id = 97;
UPDATE books SET stock = stock - 2 WHERE book_id = 108;

SELECT
    orders.order_id AS 주문번호,
    customers.name AS 손님,
    books.title AS 제목,
    order_items.quantity AS 수량,
    books.stock AS 재고
FROM orders
INNER JOIN customers ON orders.customer_id = customers.customer_id
INNER JOIN order_items ON orders.order_id = order_items.order_id
INNER JOIN books ON order_items.book_id = books.book_id
WHERE orders.order_id = (SELECT max(order_id) FROM orders)
ORDER BY books.book_id;

COMMIT;
