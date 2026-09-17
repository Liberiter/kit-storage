-- 9.2 따라 하기 5단계: 그룹 키를 둘 적으면 조합마다 한 줄이 된다
SELECT customers.city AS 도시, orders.status AS 상태, count(*) AS 주문수
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
WHERE customers.city IN ('부산', '대구')
GROUP BY customers.city, orders.status
ORDER BY 도시, 상태;
