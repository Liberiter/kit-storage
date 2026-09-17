-- 2장 2.3 «흔한 실수» — 집합 연산에 열을 더하면 행 전체를 견주게 된다
SELECT count(*) AS "주문 수" FROM orders;

SELECT customer_id AS 고객번호, order_date AS 날짜
FROM orders
EXCEPT
SELECT customer_id, review_date
FROM reviews
ORDER BY 고객번호, 날짜
LIMIT 5;
