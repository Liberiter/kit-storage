-- 입장 점검 문항 2 참조 해답 (entry_check.sh --reference 가 쓴다)
SELECT c.name, o.order_id, o.order_date
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE c.city = '춘천'
ORDER BY o.order_id;
