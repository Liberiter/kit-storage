-- 3장 3.3 «따라 하기» 4단계: 계산식에 이름을 붙여 되풀이를 없앤다
SELECT
    order_items.order_id AS 주문번호,
    order_items.book_id AS 도서번호,
    line_amount.금액,
    round(line_amount.금액 * 0.05) AS 적립금
FROM order_items
CROSS JOIN LATERAL (
    SELECT order_items.unit_price * order_items.quantity AS 금액
) AS line_amount
WHERE order_items.order_id = 5
ORDER BY order_items.book_id;
