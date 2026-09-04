-- exercise 4 해설: 배송완료 주문이 50건 이상인 도시
SELECT customers.city AS 도시, count(*) AS 배송완료주문수
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
WHERE orders.status = '배송완료'
GROUP BY customers.city
HAVING count(*) >= 50
ORDER BY 배송완료주문수 DESC, 도시;
