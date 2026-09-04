-- problem 3 (a): 동료가 쓴 질의. 취소 조건을 WHERE에 걸어 취소 주문이 없는
-- 손님이 통째로 사라진다 (고객 1~8번 중 2·4번만 남는다)
SELECT customers.customer_id, customers.name, orders.order_id, orders.status
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE customers.customer_id BETWEEN 1 AND 8 AND orders.status = '취소'
ORDER BY customers.customer_id, orders.order_id;
