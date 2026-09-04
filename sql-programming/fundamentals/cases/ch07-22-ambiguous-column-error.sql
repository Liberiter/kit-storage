-- 7.3 흔한 실수: 양쪽에 다 있는 열 이름을 한정하지 않으면 오류다
-- style.md R26의 단서(한정하지 않은 형태 자체가 설명 대상인 자리)에 해당한다
SELECT order_id, book_id, title
FROM order_items
INNER JOIN books ON order_items.book_id = books.book_id
LIMIT 3;
