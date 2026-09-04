-- 3장 exercise 3 해설: 2025년 1월 1일 이후에 나온 책
SELECT title, published_date
FROM books
WHERE published_date >= '2025-01-01' LIMIT 5;
