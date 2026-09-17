-- 9.3 따라 하기 1단계: HAVING으로 주문 20건 이상인 손님만 남긴다
-- 9.3 개념의 서식 규칙 예제(R31)와 입력이 같다(그 자리는 출력을 싣지 않는다)
SELECT
    customers.customer_id AS 고객번호,
    customers.name AS 이름,
    count(*) AS 주문수
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_id, customers.name
HAVING count(*) >= 20
ORDER BY 주문수 DESC, 고객번호;
