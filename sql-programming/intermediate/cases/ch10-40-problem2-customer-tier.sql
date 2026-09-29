-- runner: reset
-- 10장 «도전하기» problem 2 해설: 등급 함수 + 고객 뷰, 기준을 바꾸면 뷰가 따라온다
CREATE FUNCTION customer_tier(spent bigint)
RETURNS text
LANGUAGE sql
AS $$
SELECT
    CASE
        WHEN spent >= 500000 THEN '골드'
        WHEN spent >= 200000 THEN '실버'
        ELSE '브론즈'
    END AS 등급;
$$;

CREATE VIEW customer_spending AS
WITH order_totals AS (
    SELECT
        orders.customer_id,
        sum(order_items.unit_price * order_items.quantity) AS amount
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.status <> '취소'
    GROUP BY orders.customer_id
)
SELECT
    customers.customer_id,
    customers.name,
    COALESCE(order_totals.amount, 0) AS total_spent,
    customer_tier(COALESCE(order_totals.amount, 0)) AS tier
FROM customers
LEFT JOIN order_totals ON customers.customer_id = order_totals.customer_id;

SELECT tier AS 등급, count(*) AS 고객수
FROM customer_spending
GROUP BY tier
ORDER BY min(total_spent) DESC;

CREATE OR REPLACE FUNCTION customer_tier(spent bigint)
RETURNS text
LANGUAGE sql
AS $$
SELECT
    CASE
        WHEN spent >= 1000000 THEN '골드'
        WHEN spent >= 300000 THEN '실버'
        ELSE '브론즈'
    END AS 등급;
$$;

SELECT tier AS 등급, count(*) AS 고객수
FROM customer_spending
GROUP BY tier
ORDER BY min(total_spent) DESC;
