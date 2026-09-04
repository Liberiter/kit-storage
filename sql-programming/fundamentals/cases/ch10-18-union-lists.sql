-- 10.2 따라 하기 1단계: 두 명단을 UNION으로 합친다 (겹치는 사람은 한 번만).
-- 10.2 개념의 서식 규칙 예제(R35·R36)와 입력이 같다(그 자리는 출력을 싣지 않는다).
SELECT customer_id AS 고객번호
FROM orders
GROUP BY customer_id
HAVING count(*) >= 20
UNION
SELECT customer_id
FROM reviews
GROUP BY customer_id
HAVING count(*) >= 10
ORDER BY 고객번호;
