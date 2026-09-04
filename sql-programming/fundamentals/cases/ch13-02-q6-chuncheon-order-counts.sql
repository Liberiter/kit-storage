-- 13장 exit assessment 문항 6: 표준 용어로 설명할 대상 질의 (지문과 해설)
SELECT customers.name AS 손님, count(orders.order_id) AS 주문수
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE customers.city = '춘천'
GROUP BY customers.customer_id, customers.name
ORDER BY 주문수, customers.customer_id;
