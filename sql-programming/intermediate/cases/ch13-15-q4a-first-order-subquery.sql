-- 13장(exit assessment) 문항 4 지문 (가): 춘천 고객의 첫 주문 — 상관 서브쿼리
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 고객,
    o.order_id AS 주문번호,
    o.order_date AS 첫주문일
FROM customers
INNER JOIN orders AS o ON customers.customer_id = o.customer_id
WHERE customers.city = '춘천'
    AND o.order_date = (
        SELECT min(f.order_date)
        FROM orders AS f
        WHERE f.customer_id = o.customer_id
    )
ORDER BY 고객번호, 주문번호;
