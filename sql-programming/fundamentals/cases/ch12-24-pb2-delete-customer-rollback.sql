-- runner: reset
-- problem 2 해설 — 지운 뒤에 센 값이 기준을 넘어 되돌린다
BEGIN;
DELETE FROM reviews WHERE customer_id = 51;
DELETE FROM order_items
WHERE order_id IN (SELECT order_id FROM orders WHERE customer_id = 51);
DELETE FROM orders WHERE customer_id = 51;
DELETE FROM customers WHERE customer_id = 51;

SELECT count(*) AS "리뷰 없는 책"
FROM books
WHERE book_id NOT IN (SELECT book_id FROM reviews);

ROLLBACK;

SELECT count(*) AS "리뷰 없는 책"
FROM books
WHERE book_id NOT IN (SELECT book_id FROM reviews);
