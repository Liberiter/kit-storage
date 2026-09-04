-- 1장 본문이 인용하는 world 수치: 주문 없는 고객 수, 최연우(4)의 주문·항목 수,
-- 동명이인 그룹 수. (테이블별 행 수는 01-counts 케이스가 담당한다.)
SELECT '주문 없는 고객 수' AS claim,
       (SELECT count(*) FROM customers c
         WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id)) AS value
UNION ALL
SELECT '고객 4의 주문 건수', (SELECT count(*) FROM orders WHERE customer_id = 4)
UNION ALL
SELECT '고객 4의 주문 항목 행 수',
       (SELECT count(*) FROM order_items i JOIN orders o USING (order_id) WHERE o.customer_id = 4)
UNION ALL
SELECT '고객 4의 주문 중 항목이 1개뿐인 주문 수',
       (SELECT count(*) FROM (SELECT o.order_id FROM orders o JOIN order_items i USING (order_id)
                               WHERE o.customer_id = 4 GROUP BY o.order_id HAVING count(*) = 1) t)
UNION ALL
SELECT '이름이 겹치는 고객 그룹 수',
       (SELECT count(*) FROM (SELECT name FROM customers GROUP BY name HAVING count(*) > 1) t);
