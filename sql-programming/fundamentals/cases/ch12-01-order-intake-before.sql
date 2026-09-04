-- 12.1 문제 상황 — 주문을 받기 전의 장부 상태. 12.1 따라 하기 3단계에서 다시 쓴다
SELECT
    (SELECT stock FROM books WHERE book_id = 1) AS "1번 책 재고",
    (SELECT count(*) FROM orders) AS "주문 수",
    (SELECT count(*) FROM order_items) AS "항목 수";
