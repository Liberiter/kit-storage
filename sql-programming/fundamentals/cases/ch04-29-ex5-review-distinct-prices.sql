-- 4장 복습 exercise 해설 (2·3장 복습): 여행 분야의 서로 다른 정가를 비싼 순으로 5개
SELECT DISTINCT price AS "정가(원)"
FROM books
WHERE category = '여행'
ORDER BY "정가(원)" DESC
LIMIT 5;
