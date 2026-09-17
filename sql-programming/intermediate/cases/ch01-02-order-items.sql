-- 1장 1.1 «따라 하기» 1단계: 5번 주문의 항목 — 수량과 단가가 여기 있다
SELECT book_id AS 도서번호, quantity AS 수량, unit_price AS 단가
FROM order_items
WHERE order_id = 5
ORDER BY book_id;
