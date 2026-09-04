-- 8.2 따라 하기 1단계: orders → order_items → books 세 테이블을 이어 붙인다
-- 8.2 개념의 서식 규칙 예제(R28)와 입력이 같다 — 그 자리는 출력을 싣지 않는다
SELECT orders.order_id, orders.order_date, books.title, order_items.quantity
FROM orders
INNER JOIN order_items ON orders.order_id = order_items.order_id
INNER JOIN books ON order_items.book_id = books.book_id
WHERE orders.order_id = 1
ORDER BY books.book_id;
