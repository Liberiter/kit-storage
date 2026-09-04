-- 9.3 왜 그럴까요: 그룹 키에 대한 조건은 WHERE에 적는다 (권장)
-- ch09-33과 결과가 같아야 한다 (D-022)
SELECT category AS 분야, count(*) AS 권수
FROM books
WHERE category = '소설'
GROUP BY category;
