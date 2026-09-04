-- 7.3 따라 하기 3단계: 3장 조건·6장 계산과 함께 쓴다 (여행 분야, 금액 큰 순)
SELECT
    order_items.order_id,
    books.title,
    order_items.quantity * order_items.unit_price AS 금액
FROM order_items
INNER JOIN books ON order_items.book_id = books.book_id
WHERE books.category = '여행'
ORDER BY 금액 DESC, order_items.order_id
LIMIT 5;
