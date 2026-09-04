-- problem 2 해설: 금액 10만 원 이상 주문 항목의 정산 시트
SELECT
    order_id AS 주문번호,
    book_id AS 도서번호,
    quantity AS 수량,
    round(CAST(quantity * unit_price AS numeric) / 1000, 1) AS 천원
FROM order_items
WHERE quantity * unit_price >= 100000
ORDER BY 천원 DESC, order_id, book_id
LIMIT 5;
