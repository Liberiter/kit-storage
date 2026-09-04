-- 9.3 왜 그럴까요: 같은 조건을 HAVING에 적어도 결과는 같다
-- ch09-32와 결과가 같아야 한다 (D-022)
SELECT category AS 분야, count(*) AS 권수
FROM books
GROUP BY category
HAVING category = '소설';
