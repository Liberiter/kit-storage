-- 2장 2.3 «따라 하기» 2단계 — 같은 명단을 반조인으로 내면 이름·도시도 함께
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 이름,
    customers.city AS 도시
FROM customers
WHERE EXISTS (
    SELECT 1 FROM orders WHERE orders.customer_id = customers.customer_id
)
    AND NOT EXISTS (
        SELECT 1 FROM reviews WHERE reviews.customer_id = customers.customer_id
    )
ORDER BY customers.customer_id;
