-- 3장 3.3 따라 하기 3단계: NOT으로 조건 뒤집기
SELECT title, price
FROM books
WHERE NOT (price BETWEEN 10000 AND 40000) LIMIT 5;
