-- 3장 exercise 4 해설: 여행 또는 요리 분야이면서 2만 원 이상
SELECT title, category, price
FROM books
WHERE category IN ('여행', '요리') AND price >= 20000 LIMIT 5;
