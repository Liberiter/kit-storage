-- 2장 2.3 «practice» 2 — 주문도 리뷰도 없는 고객을 이름·도시와 함께
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 이름,
    customers.city AS 도시
FROM customers
WHERE NOT EXISTS (
    SELECT 1 FROM orders WHERE orders.customer_id = customers.customer_id
)
    AND NOT EXISTS (
        SELECT 1 FROM reviews WHERE reviews.customer_id = customers.customer_id
    )
ORDER BY customers.customer_id;
