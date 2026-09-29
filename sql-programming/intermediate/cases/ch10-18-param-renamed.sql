-- runner: reset
-- 10장 10.2 «흔한 실수»: 매개변수 이름을 열과 겹치지 않게 지으면 고객마다 센다
CREATE FUNCTION order_count(buyer_id integer)
RETURNS bigint
LANGUAGE sql
AS $$
SELECT count(*) AS 주문수 FROM orders WHERE customer_id = buyer_id;
$$;

SELECT customer_id, order_count(customer_id) AS 주문수
FROM customers
WHERE customer_id <= 3
ORDER BY customer_id;
