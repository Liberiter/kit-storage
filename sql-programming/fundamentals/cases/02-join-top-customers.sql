-- smoke: 조인+집계+정렬+LIMIT (3테이블 경로)
SELECT c.name, c.city, count(*) AS order_count
  FROM customers c
  JOIN orders o USING (customer_id)
 GROUP BY c.customer_id, c.name, c.city
 ORDER BY order_count DESC, c.customer_id
 LIMIT 5;
