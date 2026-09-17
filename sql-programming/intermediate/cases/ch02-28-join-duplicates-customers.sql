-- 2장 2.3 «따라 하기» 6단계 — 조인으로 이으면 짝의 수만큼 줄이 늘어난다
SELECT count(*) AS "조인한 줄 수"
FROM orders
INNER JOIN reviews ON orders.customer_id = reviews.customer_id;
