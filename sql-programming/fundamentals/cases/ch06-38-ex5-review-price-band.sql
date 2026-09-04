-- 복습 exercise 해설 (2장 DISTINCT·별칭 + 4장 ORDER BY·LIMIT + 6.1 정수 나눗셈)
SELECT DISTINCT price / 10000 AS "만 원 단위"
FROM books
ORDER BY "만 원 단위" DESC
LIMIT 3;
