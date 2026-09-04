-- 1장 exercise 3 근거: 이름 '최연우'는 유일하지 않다 (동명이인 3명, 도시도 각각
-- 다르고 셋 다 주문을 갖고 있다 — 이름으로 출발하면 남의 주문이 딸려 온다).
SELECT c.customer_id, c.name, c.email, c.city, count(o.order_id) AS orders
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE c.name = '최연우'
GROUP BY c.customer_id, c.name, c.email, c.city
ORDER BY c.customer_id;
