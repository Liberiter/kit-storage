-- 3장 problem 3 해설: 동료의 0행 질의를 고친 것 (AND -> IN)
SELECT title, category
FROM books
WHERE category IN ('여행', '요리') AND price <= 15000 LIMIT 5;
