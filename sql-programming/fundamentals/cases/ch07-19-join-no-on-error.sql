-- 7.3 왜 그럴까요: ON을 빼면 문법 오류다 (조인 조건은 선택이 아니다)
SELECT order_items.order_id, books.title
FROM order_items
INNER JOIN books
LIMIT 3;
