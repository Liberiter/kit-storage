-- exercise 1 해설: 세 권씩 나간 주문 항목의 금액 (2장 별칭 + 6.1 계산)
SELECT
    order_id AS 주문번호,
    book_id AS 도서번호,
    quantity AS 수량,
    unit_price AS 단가,
    quantity * unit_price AS 금액
FROM order_items
WHERE quantity = 3
ORDER BY 금액 DESC, order_id, book_id
LIMIT 5;
