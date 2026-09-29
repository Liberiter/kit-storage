-- runner: reset
-- 10장 10.2 «흔한 실수»: 매개변수 이름이 열 이름과 같으면 열이 이긴다 — 모두 620
CREATE FUNCTION order_count(customer_id integer)
RETURNS bigint
LANGUAGE sql
AS $$
SELECT count(*) AS 주문수 FROM orders WHERE customer_id = customer_id;
$$;

SELECT customer_id, order_count(customer_id) AS 주문수
FROM customers
WHERE customer_id <= 3
ORDER BY customer_id;
