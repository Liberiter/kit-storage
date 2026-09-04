-- 10.2 따라 하기 5단계: 구분 라벨을 붙여 두 명단을 한 표로 만든다.
-- 10.2 개념의 서식 규칙 예제(R37)와 입력이 같다(그 자리는 출력을 싣지 않는다).
SELECT '단골' AS 구분, customer_id AS 고객번호
FROM orders
GROUP BY customer_id
HAVING count(*) >= 20
UNION ALL
SELECT '리뷰어', customer_id
FROM reviews
GROUP BY customer_id
HAVING count(*) >= 10
ORDER BY 구분, 고객번호;
