-- 2장 2.2 «practice» 1 — 주문을 한 번도 하지 않은 고객
SELECT count(*) AS 인원
FROM customers
WHERE NOT EXISTS (
    SELECT 1 FROM orders WHERE orders.customer_id = customers.customer_id
);
