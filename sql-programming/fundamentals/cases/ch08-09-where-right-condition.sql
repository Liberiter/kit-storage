-- 8.1 흔한 실수: LEFT JOIN을 써 놓고 오른쪽 테이블의 열을 WHERE에 걸면
-- 짝이 없는 행이 다시 버려져 내부 조인과 같아진다 (7번 조유나가 사라진다)
SELECT customers.customer_id, customers.name, orders.order_id, orders.order_date
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE customers.customer_id BETWEEN 6 AND 9
    AND orders.order_date >= '2026-01-01'
ORDER BY customers.customer_id, orders.order_id;
