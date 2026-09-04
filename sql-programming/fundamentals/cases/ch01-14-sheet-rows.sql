-- 1장 1.1 문제 상황의 '사장님 주문 시트' 표 5줄이 world와 일치하는지 확인한다.
-- (시트는 전체가 아니라 일부다 — 표에 실린 주문·도서 조합만 대조한다.)
WITH sheet(order_id, book_id, seq) AS (
  VALUES (122, 269, 1), (196, 228, 2), (196, 66, 3), (196, 162, 4), (618, 228, 5)
)
SELECT o.order_date AS "주문일", c.name AS "고객이름", c.city AS "고객도시",
       c.email AS "고객이메일", b.title AS "책제목", b.author AS "저자",
       b.price AS "정가", i.quantity AS "수량"
FROM sheet s
JOIN orders o ON o.order_id = s.order_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN books b ON b.book_id = s.book_id
JOIN order_items i ON i.order_id = s.order_id AND i.book_id = s.book_id
ORDER BY s.seq;
