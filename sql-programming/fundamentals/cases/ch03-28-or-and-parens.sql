-- 3장 3.3 왜 그럴까요: 괄호로 OR를 먼저 묶은 질의 (ch03-27과 결과가 다르다)
SELECT title, category, price
FROM books
WHERE (category = '여행' OR category = '요리') AND price <= 10000;
