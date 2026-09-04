-- 13장 exit assessment 문항 11 해설: 도시별 배송완료 매출 (스칼라 서브쿼리 + HAVING)
SELECT
    customers.city AS 도시,
    count(*) AS 항목수,
    sum(order_items.quantity * order_items.unit_price) AS 매출
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
INNER JOIN order_items ON orders.order_id = order_items.order_id
INNER JOIN books ON order_items.book_id = books.book_id
WHERE orders.status = '배송완료'
    AND books.price >= (SELECT avg(price) FROM books)
GROUP BY customers.city
HAVING sum(order_items.quantity * order_items.unit_price) >= 2000000
ORDER BY 매출 DESC, 도시;
