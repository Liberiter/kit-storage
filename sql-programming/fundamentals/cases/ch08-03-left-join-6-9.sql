-- 8.1 따라 하기 1단계: INNER를 LEFT로 바꾸면 조유나가 널과 함께 남는다
-- 8.1 개념의 서식 규칙 예제(R27)와 입력이 같다 — 그 자리는 출력을 싣지 않는다
SELECT customers.customer_id, customers.name, orders.order_id, orders.order_date
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE customers.customer_id BETWEEN 6 AND 9
ORDER BY customers.customer_id, orders.order_id;
