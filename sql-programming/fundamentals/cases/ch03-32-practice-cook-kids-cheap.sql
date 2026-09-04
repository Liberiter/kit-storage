-- 3장 3.3 practice 2 풀이: (요리 또는 어린이) 이면서 1만 원 미만
SELECT title, category, price
FROM books
WHERE (category = '요리' OR category = '어린이') AND price < 10000;
