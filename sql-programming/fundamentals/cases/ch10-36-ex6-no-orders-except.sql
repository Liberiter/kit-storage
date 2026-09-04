-- 복습 exercise 6 (8장) 해설 (나): 같은 답을 EXCEPT로. ch10-35와 기대 출력이 같다
SELECT customer_id AS 고객번호
FROM customers
EXCEPT
SELECT customer_id
FROM orders
ORDER BY 고객번호
LIMIT 5;
