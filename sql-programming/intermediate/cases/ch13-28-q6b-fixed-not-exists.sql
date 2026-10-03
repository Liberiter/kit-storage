-- 13장(exit assessment) 문항 6 (나) 해설: NOT EXISTS로 고친 리뷰 요청 대상
SELECT
    orders.order_id AS 주문번호,
    customers.customer_id AS 고객번호,
    customers.name AS 고객,
    orders.shipped_date AS 발송일
FROM orders
INNER JOIN customers ON orders.customer_id = customers.customer_id
WHERE orders.status = '배송완료'
    AND orders.shipped_date >= '2026-08-01'
    AND NOT EXISTS (
        SELECT 1 FROM reviews WHERE reviews.order_id = orders.order_id
    )
ORDER BY 발송일, 주문번호;
