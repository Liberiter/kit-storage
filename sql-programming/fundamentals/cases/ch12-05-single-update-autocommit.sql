-- runner: reset
-- 12.1 왜 그럴까요 — 트랜잭션으로 묶지 않은 문장 하나만 실행한 장부
UPDATE books SET stock = stock - 1 WHERE book_id = 1;

SELECT
    (SELECT stock FROM books WHERE book_id = 1) AS "1번 책 재고",
    (SELECT count(*) FROM orders) AS "주문 수",
    (SELECT count(*) FROM order_items) AS "항목 수";
