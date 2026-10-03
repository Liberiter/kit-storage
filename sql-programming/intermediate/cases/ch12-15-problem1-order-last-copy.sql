-- runner: reset
-- 12장 도전하기 problem 1 해설: 재고가 남았을 때만 줄이고 그 결과로 주문을 만드는 한 문장을 두 번 (혼자 실행)
WITH sold AS (
    UPDATE books
    SET stock = stock - 1
    WHERE book_id = 6 AND stock >= 1
    RETURNING book_id, price
),
new_order AS (
    INSERT INTO orders (customer_id, order_date, status)
    SELECT 1, '2026-09-01', '배송준비'
    FROM sold
    RETURNING order_id
)
INSERT INTO order_items (order_id, book_id, quantity, unit_price)
SELECT order_id, 6, 1, (SELECT price FROM sold)
FROM new_order
RETURNING order_id, book_id, unit_price;

WITH sold AS (
    UPDATE books
    SET stock = stock - 1
    WHERE book_id = 6 AND stock >= 1
    RETURNING book_id, price
),
new_order AS (
    INSERT INTO orders (customer_id, order_date, status)
    SELECT 2, '2026-09-01', '배송준비'
    FROM sold
    RETURNING order_id
)
INSERT INTO order_items (order_id, book_id, quantity, unit_price)
SELECT order_id, 6, 1, (SELECT price FROM sold)
FROM new_order
RETURNING order_id, book_id, unit_price;

SELECT
    (SELECT stock FROM books WHERE book_id = 6) AS 재고,
    (SELECT count(*) FROM orders) AS 주문수,
    (SELECT count(*) FROM order_items) AS 항목수;
