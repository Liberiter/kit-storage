-- 4장 4.1 따라 하기 4단계: WHERE로 고른 뒤 ORDER BY로 세운다 (여행 & 12000원 이하)
SELECT title, price
FROM books
WHERE category = '여행' AND price <= 12000
ORDER BY price;
