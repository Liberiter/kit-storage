-- 3장 problem 1 해설: 여행 도서전 매대 목록 (여행 분야, 2만 원 이하)
SELECT title AS 제목, price AS "정가(원)"
FROM books
WHERE category = '여행' AND price <= 20000 LIMIT 5;
