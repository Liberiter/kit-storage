-- 4장 4.2 따라 하기 4단계: 남은 행이 LIMIT보다 적으면 있는 만큼만 나온다
SELECT title, price
FROM books
WHERE category = '요리' AND price <= 9000
ORDER BY price
LIMIT 10;
